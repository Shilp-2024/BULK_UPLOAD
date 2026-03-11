Feature: Contacts Bulk Upload and consent mapping for Club communication
  In order to enable clubs to reach offline contacts
  As a Club Admin/PRO
  I want to upload CSV contact files, create accounts silently for new contacts, attest consents, attach to Lists, and ensure send-time eligibility is enforced.

  Background:
    Given I am signed in as a Club Admin with "Bulk import contacts" permission
    And the club-level feature flag for Bulk Import Contacts is enabled

  # ====== HAPPY PATH: Complete bulk import workflow ======
  Scenario: HAPPY-PATH-001 End-to-end successful bulk import workflow
    Given I am on the Bulk Import Contacts page
    And I have a valid CSV file with 100 contacts (95 new, 5 existing)
    When I upload the CSV file
    Then the system validates successfully with 0 invalid rows
    And I land on the Review step
    When I attest "General club news and club marketing" and "Lotto notifications"
    And I select "Create new Static List" named "Spring 2026 Campaign"
    And I click "Confirm Import"
    Then 95 new accounts are created silently
    And 95 verification emails are sent to new contacts
    And all 100 contacts are added to "Spring 2026 Campaign"
    And an audit record captures {uploader_id, timestamp, consent_flags}
    And a confirmation email is sent to my account with non-PII summary
    And I see success message with import batch ID

  Scenario: HAPPY-PATH-002 Verification and eligibility flow for uploaded contacts
    Given a bulk import completed with 50 new contacts
    And all 50 are marked as "Not verified"
    When 30 contacts verify their email within 24 hours
    Then those 30 are marked as "Verified"
    And their MyAccount preferences are populated with consent flags (Marketing=Yes, Lotto=Yes)
    And those 30 become eligible for Marketing and Lotto email sends
    When I compose a Marketing email to "Spring 2026 Campaign" list
    Then the system shows "Matched: 50, Eligible: 30" (20 suppressed as unverified)
    And only 30 contacts receive the email when sent

  Scenario: HAPPY-PATH-003 Add imported contacts to existing list
    Given I have an existing list "Loyal Members" with 200 contacts
    And I upload a CSV with 50 new contacts
    When I select "Add to existing" and choose "Loyal Members"
    And I complete the import
    Then all 50 new contacts are added to "Loyal Members"
    And "Loyal Members" now contains 250 unique contacts (no duplicates)
    And the import completes successfully

  Scenario: HAPPY-PATH-004 Lotto consent and list management
    Given I upload a CSV with 75 contacts
    When I attest "Lotto notifications" consent for the batch
    And I select "Add to Active lotto players"
    And I complete the import with batch ID "BATCH-2026-001"
    Then all 75 contacts are added to "Active lotto players"
    And an audit record logs {batch_id, uploader, timestamp, lotto_consent=Yes}
    And upon verification, contacted are eligible to receive lotto results emails

  # ====== FR-001 Access Control & Entry ======
  Scenario: FR-001.S01 Authorized user can access Bulk Import
    Given I am signed in as a Club Admin with "Bulk import contacts" permission
    When I open the Back Office
    Then I see "Bulk import contacts" as an enabled entry
    When I click "Bulk import contacts"
    Then I land on the Bulk import contacts main page

  Scenario: FR-001.S02 Club feature flag disabled hides Bulk Import
    Given I am signed in as a Club Admin with "Bulk import" permission
    And the club-level feature flag for Bulk Import is disabled
    When I open the Bulk import side menu
    Then "Bulk Import" is not visible or is disabled with explanatory tooltip

  Scenario: FR-001.S03 Permission denied blocks deep link
    Given I am signed in as a Club admin user without "Bulk import" permission
    When I navigate directly to /bulk-import
    Then I see the bulk import contacts page greyed out and not selectable

  # ====== FR-002 Bulk Import Launcher ======
  Scenario: FR-002.S01 Launcher presents three import types
    Given I am authorized to use Bulk Import
    When I land on the Bulk Import launcher
    Then I see tiles for "Contacts", "Membership registrations", and "Lotto playslips"

  Scenario: FR-002.S02 Contacts tile opens the Contacts flow
    Given I am on the Bulk Import launcher
    When I click "Contacts"
    Then I land on Contacts Upload - Step 1 (CSV Upload & Instructions)

  Scenario: FR-002.S03 Membership tile opens the Membership flow
    Given I am on the Bulk Import launcher
    When I click "Membership registrations"
    Then I land on Membership bulk upload page

  Scenario: FR-002.S04 Playslips tile opens the Lotto flow
    Given I am on the Bulk Import launcher
    When I click "Playslips"
    Then I land on Lotto playslips upload page

  # ====== FR-003 CSV Upload & Validation & File Type Validation ======
  Scenario: FR-003.S01 Valid CSV advances to Review
    Given I am on Bulk upload contacts Step 1
    And I see the instruction "Columns A/B/C = First Name / Last Name / Email (header required)"
    When I upload a valid CSV file with correct header and all valid rows
    Then the file parses successfully
    And I advance to the Review step with 0 invalid rows
    And "Continue" button is enabled

  Scenario: FILE-TYPE-001 Only CSV file type accepted
    Given I am on Bulk upload contacts Step 1
    When I attempt to upload an Excel file (.xlsx)
    Then the system rejects the file with error "Only CSV files are accepted"
    And the upload form remains on Step 1
    When I attempt to upload a JSON file (.json)
    Then the system rejects the file with error "Only CSV files are accepted"
    When I attempt to upload a TXT file (.txt)
    Then the system rejects the file with error "Only CSV files are accepted"

  Scenario: FILE-TYPE-002 CSV encoding must be UTF-8 compatible
    Given I am on Bulk upload contacts Step 1
    When I upload a CSV file with UTF-8 encoding
    Then the file parses successfully without encoding errors
    When I upload a CSV file with UTF-8 BOM encoding
    Then the file parses successfully (BOM handled automatically)
    When I upload a CSV file with ISO-8859-1 encoding
    Then the system rejects with error "Unsupported file encoding. Please use UTF-8"

  Scenario: FILE-TYPE-003 CSV must have correct header row
    Given I am on Contacts Upload - Step 1
    When I upload a CSV without a header row (data starts on row 1)
    Then the system shows inline error "Header required: First Name, Last Name, Email"
    And the Continue/Next button remains disabled
    When I upload a CSV with incorrect header (e.g., "Name, Email, Phone")
    Then system error "Invalid header. Expected columns: First Name, Last Name, Email"
    When I upload a CSV with correct header in row 2 instead of row 1
    Then parsing fails with "Header must be in row 1"
  Scenario: FR-003.S01 Valid CSV advances to Review
    Given I am on Bulk upload contacts Step 1
    And I see the instruction "Columns A/B/C = First Name / Last Name / Email (header required)"
    When I upload a CSV with the correct header and all valid rows
    Then the file parses successfully
    And I advance to the Review step with 0 invalid rows

  Scenario: FR-003.S02 Missing header row blocks parse
    Given I am on Contacts Upload - Step 1
    When I upload a CSV without a header row
    Then the system shows an inline error "Header required: First Name, Last Name, Email"
    And the Continue/Next button remains disabled

  # ====== Validation Errors: Required Fields ======
  Scenario Outline: FR-003.S03 Required field blank marks row invalid
    Given I uploaded a CSV with a header row
    When the system validates row <Row>
    Then the row is marked "Invalid"
    And the reason lists "<Field> is required"
    And I cannot continue until all invalids are resolved
    Examples:
      | Row | Field      |
      | 2   | First name |
      | 4   | Last name  |
      | 10  | Email      |

  Scenario: VALIDATION-001 Multiple blank fields in single row
    Given I upload a CSV with row 5: First Name blank, Last Name "Smith", Email blank
    When validation runs
    Then row 5 is marked "Invalid"
    And the error message shows "First name is required, Email is required"

  Scenario: VALIDATION-002 All required fields blank
    Given I upload a CSV with row 8: all three fields blank
    When validation runs
    Then row 8 marked "Invalid"
    And error shows "First name is required, Last name is required, Email is required"

  # ====== Validation Errors: Email Format ======
  Scenario Outline: FR-003.S04 Invalid email format marks row invalid
    Given I uploaded a CSV with a header row
    When the system validates row <Row> with Email "<Email>"
    Then the row is marked "Invalid" with reason "Invalid email format"
    And continue is blocked
    Examples:
      | Row | Email               |
      | 2   | alice@@domain.com   |
      | 4   | bob.domain.com      |
      | 10  | charlie@domain      |

  Scenario: VALIDATION-003 Email edge cases
    Given I upload a CSV with various email formats:
      | Row | Email                      | Expected       |
      | 2   | user+tag@example.com       | Valid          |
      | 3   | user.name@example.co.uk    | Valid          |
      | 4   | user_name@example.com      | Valid          |
      | 5   | user@sub.domain.example.io | Valid          |
      | 6   | user@                      | Invalid format |
      | 7   | @example.com               | Invalid format |
      | 8   | user@.com                  | Invalid format |
      | 9   | user name@example.com      | Invalid format |
    When validation completes
    Then rows 2-5 are valid and rows 6-9 marked invalid with "Invalid email format"

  # ====== Duplicate Contact Scenarios ======
  Scenario: FR-003.S05 In-file duplicate emails (same CSV)
    Given I uploaded a CSV containing repeated email "johndoe@club.ie" on rows 2 and 5
    When validation completes
    Then row 2 is kept as the canonical record
    And row 5 is flagged "Duplicate in file (ignored)"
    And proceed is allowed if there are no other invalids

  Scenario: DUPLICATE-001 Multiple in-file duplicates
    Given I upload a CSV with email "alice@club.ie" on rows 2, 5, 9
    When validation runs
    Then row 2 is kept (canonical)
    And row 5 flagged "Duplicate in file (ignored)"
    And row 9 flagged "Duplicate in file (ignored)"
    And system summary shows "2 duplicates ignored; 1 record processed"

  Scenario: DUPLICATE-002 Existing account suppression (system duplicate)
    Given the system has existing account for "existing.user@club.ie"
    When I upload CSV with row 3: "existing.user@club.ie" (name "John Doe")
    Then row 3 shows Warning "Existing account found for existing.user@club.ie"
    And row 3 is valid (not invalid)
    And can proceed with import

  Scenario: DUPLICATE-003 Existing account with name mismatch (soft-merge)
    Given the system has existing account: Email=johndoe@club.ie, First=John, Last=Doe
    And the CSV row is: Email=johndoe@club.ie, First=Johnny, Last=Doe
    When validation runs
    Then the row shows Warning "Name mismatch with existing account. First name and last name will be updated from this account upon upload"
    And row is marked valid (warning, not invalid)
    When I complete the import
    Then the existing account name remains (John Doe) - not updated
    And the imported batch record notes this was an existing account

  Scenario: DUPLICATE-004 Case-insensitive email deduplication
    Given I upload CSV with rows:
      | Row | Email           |
      | 2   | John@Club.IE    |
      | 5   | john@club.ie    |
    When validation completes
    Then row 2 kept as canonical
    And row 5 flagged "Duplicate in file (ignored)"
    And system recognizes both as same email (case-insensitive)

  Scenario: DUPLICATE-005 Email with whitespace trimming (dedup)
    Given I upload CSV with rows:
      | Row | Email             |
      | 2   | john@club.ie      |
      | 5   | " john@club.ie "  |
    When validation runs
    Then row 5 whitespace trimmed to "john@club.ie"
    And row 5 flagged as duplicate of row 2
    And both recognized as same email after normalization

  # ====== Maximum Upload Limit Scenarios ======
  Scenario: FR-003.S07 Row count limit exceeded blocks parse
    Given the row cap is set to 1000 rows
    When I upload a CSV with 1001 rows (excluding header)
    Then parsing is blocked with error "File exceeds maximum row count (1001 rows, limit is 1000)"
    And no partial processing occurs
    And Continue button remains disabled

  Scenario: LIMIT-001 Exact row count limit accepted
    Given the row cap is 1000 rows
    When I upload a CSV with exactly 1000 data rows (plus header = 1001 lines total)
    Then the file parses successfully
    And validation proceeds normally

  Scenario: LIMIT-002 One row below limit accepted
    Given the row cap is 1000 rows
    When I upload a CSV with 999 data rows
    Then the file parses successfully and validation proceeds

  Scenario: LIMIT-003 File size limit exceeded blocks parse
    Given the file size cap is 10 MB
    When I upload a CSV file of 10.5 MB
    Then parsing is blocked with error "File exceeds maximum size (10.5 MB, limit is 10 MB)"
    And no partial processing occurs
    And Continue button remains disabled

  Scenario: LIMIT-004 Exact file size limit accepted
    Given the file size cap is 10 MB
    When I upload a CSV file exactly 10 MB
    Then the file parses successfully and validation proceeds

  Scenario: LIMIT-005 Large file with many columns (only 3 required)
    Given row cap is 1000, file size cap is 10 MB
    And CSV has 3 columns (First Name, Last Name, Email) plus extra columns
    When I upload 1000 rows × 3 columns (minimal data)
    Then file size well under 1 MB and parsing succeeds
    And extra columns are ignored (not validated)

  Scenario: LIMIT-006 Both limits exceeded simultaneously
    Given row cap is 1000, file size cap is 10 MB
    When I upload a CSV with 1500 rows AND 12 MB size
    Then parsing blocked with error "File exceeds row count AND size limits"
    And both limits shown in error message

  Scenario: LIMIT-007 Performance requirement: validation within 10 seconds
    Given I upload a CSV with 1000 valid rows
    When validation runs
    Then the validation completes within 10 seconds
    And the system displays progress indicator during validation
    And user is not blocked from UI interaction


  # ====== Data Normalization & Edge Cases ======
  Scenario: FR-003.S09 Encoding and whitespace normalization
    Given I upload a CSV with trailing spaces and mixed case
    When validation runs
    Then leading/trailing whitespace is trimmed
    And name and email comparisons use canonicalisation rules

  Scenario: NORMALIZATION-001 Whitespace trimming in all fields
    Given I upload CSV with row 3: " John " | " Doe " | " john@club.ie "
    When validation runs
    Then the row is trimmed to: "John" | "Doe" | "john@club.ie"
    And row marked valid (if all other rules pass)

  Scenario: NORMALIZATION-002 Email canonicalization for matching
    Given I upload CSV with emails in mixed case: "JOHN@CLUB.IE", "John@Club.IE", "john@club.ie"
    When validation runs
    Then all are canonicalized to lowercase "john@club.ie"
    And duplicates detected (rows 2 and 3 marked as duplicates of row 1)

  Scenario: NORMALIZATION-003 Special characters and accents preserved
    Given I upload CSV with rows:
      | First Name | Last Name | Email              |
      | François   | Müller    | francois@club.ie   |
      | Jean-Paul  | O'Brien   | jeanpaul@club.ie   |
    When validation runs
    Then special characters preserved in names (François, Müller, Jean-Paul, O'Brien)
    And rows marked valid

  Scenario: FR-003.S08 No downloadable error file; re-upload required
    Given I see 25 invalid rows listed inline on Step 1
    Then the UI displays each invalid row with specific error reasons
    And I see message "Please correct these rows in your source file and re-upload"
    And no "Download error report" button is available
    And I must manually fix CSV and re-upload

  # ====== FR-004 Silent Account Creation & Verification ======
  Scenario: FR-004.S01 Create account and send verification for new email
    Given row 2 contains email "new@club.ie" not in the system
    When I complete the validated import
    Then a Clubforce account is created silently for "new@club.ie"
    And a verification email is sent to "new@club.ie"
    And the contact is marked Not verified and ineligible for non-transactional sends

  Scenario: FR-004.S02 Existing email does not receive a notification
    Given row 3 contains email "existing@club.ie" which already has an account
    When I complete the import
    Then no verification or notification is sent to "existing@club.ie"
    And the row is accepted if name matches per rules

  Scenario: FR-004.S03 Login-based resend verification (nice to have)
    Given I am an unverified contact with a valid password
    When I attempt to log in
    Then I see an option "Resend verification"
    And when I click it
    Then the system sends a fresh verification and invalidates any prior token

  Scenario: FR-004.S04 Hard bounce marks UNDELIVERABLE
    Given a verification email to "bad@club.ie" hard bounces
    When the ESP webhook is received
    Then the contact's deliverability is set to false
    And suppression reason UNDELIVERABLE is applied for future sends

  Scenario: FR-004.S05 Verification completion unlocks eligibility
    Given a contact was Not verified
    When the contact completes verification
    Then their status becomes Verified
    And they become eligible for Marketing sends subject to consent rules

  Scenario: FR-004.S06 Per-upload toggle defaults ON to send 'account created' email
    Given I am on the import club contacts page and see the toggle is ON by default
    When I complete the import that creates 25 new accounts
    Then the system sends the 'account created' email and verification email to those new accounts

  Scenario: FR-004.S07 Turning the toggle OFF skips the 'account created' email but still sends verification
    Given the toggle is visible and ON
    When I switch the toggle to OFF and complete an import creating 10 new accounts
    Then the system does NOT send the 'account created' email and still sends verification emails

  # ====== FR-005 Lists (Static & Lotto) ======
  Scenario: FR-005.S01 Create Static List at upload
    Given I chose "Create new Static List" and named it "2026 Diaspora"
    When I complete a 100% valid import
    Then all imported contacts are added to "2026 Diaspora"

  Scenario: FR-005.S02 Add to existing Static List
    Given I selected existing list "Life members" and some imported contacts are already on it
    When I complete the import
    Then only missing contacts are added and no duplicate list is created

  Scenario: FR-005.S03 Add to Active/Expired lotto lists with consent
    Given I ticked Lotto consent attestation for this batch
    When I select "Active lotto players" as a target list
    Then imported contacts are added to Active lotto players
    And Lotto players - Expired is not visible to be selected

  Scenario: FR-005.S04 Block adding to lotto lists without consent
    Given I did not tick Lotto consent attestation
    When I attempt to select "Active lotto players"
    Then selection is blocked with an explanatory message

  # ====== FR-006 Consent Attestation & MyAccount Mapping ======
  Scenario: FR-006.S01 Immediate audit on attestation
    Given I tick "General club news and club marketing consent" and "Lotto result notifications" on Import Options
    When I confirm and move past Options
    Then the system writes an audit record containing uploader id, timestamp, file, and consent flags

  Scenario: FR-006.S02 Map attested consent after verification
    Given "paul@club.ie" is part of the attested batch and is Not verified
    When Paul verifies his account
    Then his per-club preferences in MyAccount show Marketing=Yes and Lotto=Yes if attested

  Scenario: FR-006.S03 Defaults with no attestation
    Given no consent boxes were ticked for the batch
    When contacts verify
    Then their Marketing and Lotto are set to Unset

  Scenario: FR-006.S07 Do not override existing preferences
    Given contact "ben@club.ie" already has Marketing = No and Lotto = Yes
    When the batch attests Marketing = Yes and Lotto = Yes and the contact verifies
    Then Ben's existing preferences remain unchanged

  Scenario: FR-006.S08 Mixed batch with set and unset preferences
    Given mixed existing preferences across contacts in a batch
    When upload is processed and contacts verify
    Then only unset preferences are populated from attestation; existing prefs remain

  # ====== FR-007 Send-time Eligibility & Unverified Suppression ======
  Scenario: FR-007.S01 Marketing eligibility rules
    Given I am composing a marketing email
    When the system computes eligibility
    Then only contacts with Verified = true AND General club news and club marketing = Yes receive the email

  Scenario: FR-007.S02 Transactional bypass for receipts/password/welcome
    Given I am composing a Transactional email
    When the system computes eligibility
    Then recipients are not blocked by Marketing consent (unless channel rules require verification)

  Scenario: FR-007.S03 Lotto results allowed when Lotto consent exists
    Given I am sending Lotto results email and audience includes contacts added via import with Lotto consent
    When the system computes eligibility
    Then those contacts are Eligible for lotto results email

  Scenario: FR-007.S04 Platform-wide unverified suppression
    Given an Account holder is not verified
    When any non-transactional email is sent
    Then the contact is suppressed with reason UNVERIFIED

  # ====== FR-008 MyAccount Preferences & Migration Defaults ======
  Scenario: FR-008.S01 Migration defaults for existing Email=Yes
    Given an existing Account Holder had Email=Yes before release
    When this project is released
    Then general club news and club marketing becomes Yes in MyAccount

  Scenario: FR-008.S02 Migration sets Lotto=Yes for historical lotto entrants
    Given an existing AH previously purchased a lotto ticket
    When this project is released
    Then their per-club Lotto notifications = Yes

  Scenario: FR-008.S03 User updates per-club preferences
    Given I am a verified user in MyAccount
    When I set General club news and club marketing =Yes and Lotto notifications=Yes for a club
    Then subsequent eligibility checks include me

  # ====== FR-009 Compose Emails ======
  Scenario: FR-009.S01 Default to Marketing and show counts
    Given I open the compose screen and select a Static List
    When the system computes recipients
    Then classification is Marketing by default and Counts show Matched vs Eligible

  Scenario: FR-009.S02 Deduplicate recipients across lists
    Given I select multiple lists with overlapping recipients
    When the system computes recipients
    Then Matched reflects deduplicated unique emails and Eligible computed accordingly

  Scenario: FR-009.S05 Transactional override requires explicit confirmation
    Given classification is Marketing and Matched > Eligible
    When I check the confirmation checkbox and proceed
    Then classification is set to Transactional for this send only and send proceeds

  Scenario: FR-009.S06 Recurring emails re-evaluate at send time
    Given I scheduled a recurring email
    When a scheduled occurrence is about to send
    Then the system recomputes Matched, Eligible, and Suppressed using current data

  # ====== FR-010 Split Lotto & Draw players ======
  Scenario: FR-010.S01 Recipients dropdown shows active and expired lotto lists
    Given I am on compose screen
    When I open recipient picker
    Then I see "Lotto players - active" and "Lotto players - expired" and not legacy "Lotto players"

  Scenario: FR-010.S02 Legacy recurring email mapping to active lotto players
    Given a recurring email uses legacy "Lotto players"
    When system loads the recurring config
    Then it is mapped to "Lotto players - active"

  # ====== FR-011 System-Defined Dynamic Recipient List ======
  Scenario: FR-011 All club contacts system list visible and de-duplicated
    Given club has members, lotto purchasers, shop purchasers, club users, and guardians
    When I open recipient picker
    Then I see read-only list "All club contacts" that aggregates unique contacts from all sources

  # ====== FR-012 Admin Confirmation Email ======
  Scenario: FR-012.S01 Send confirmation email upon successful import
    Given I have uploaded a CSV that validates to 100% with zero invalid rows
    When the import completes and records are committed
    Then the system sends a confirmation email to the uploader
    And the email is classified as Transactional/Operational and contains non-PII summary

  Scenario: FR-012.S02 Send email on failed or aborted import
    Given the import fails validation or is aborted before commit
    When the process ends
    Then an email is sent to the uploader with relevant (non-PII) information
