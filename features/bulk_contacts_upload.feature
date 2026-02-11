Feature: Contacts Bulk Upload and consent mapping for Club communication
  In order to enable clubs to reach offline contacts
  As a Club Admin/PRO
  I want to upload CSV contact files, create accounts silently for new contacts, attest consents, attach to Lists, and ensure send-time eligibility is enforced.

  Background:
    Given I am signed in as a Club Admin with "Bulk import contacts" permission
    And the club-level feature flag for Bulk Import Contacts is enabled

  # FR-001 Access & Launcher
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

  # FR-002 Bulk Import Launcher
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

  # FR-003 CSV Upload & Validation
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

  Scenario: FR-003.S05 In-file duplicate emails are ignored after first
    Given I uploaded a CSV containing repeated email "johndoe@club.ie" on rows 2 and 5
    When validation completes
    Then row 2 is kept as the canonical record
    And row 5 is flagged "Duplicate in file (ignored)"
    And proceed is allowed if there are no other invalids

  Scenario: FR-003.S06 Existing account + name mismatch handling (soft-merge)
    Given the system finds an existing account for email "johndoe@club.ie" with First=John Last=Doe
    And the uploaded row has First=Johnny Last=Doe
    When the admin uploads the csv and the validation runs
    Then the row shows a Warning "Name mismatch with existing account. First name and last name will be updated from this account upon upload"
    And on commit the imported record keeps the existing account name (system authoritative)

  Scenario: FR-003.S07 File caps exceeded block parse
    Given the row cap is 5000 and size cap is 10 MB
    When I upload a CSV with 6000 rows or >10 MB
    Then parsing is blocked with a clear error stating the exceeded limit
    And no partial processing occurs

  Scenario: FR-003.S08 No inline error file; re-upload required
    Given I see invalid rows listed inline
    Then the UI explains I must correct the source file and re-upload

  Scenario: FR-003.S09 Encoding and whitespace normalization
    Given I upload a CSV with trailing spaces and mixed case
    When validation runs
    Then leading/trailing whitespace is trimmed
    And name and email comparisons use canonicalisation rules

  # FR-004 Silent Account Creation & Verification
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

  # FR-005 Lists (Static & Lotto)
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

  # FR-006 Consent Attestation & MyAccount Mapping
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

  # FR-007 Send-time Eligibility & Unverified Suppression
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

  # FR-008 MyAccount Preferences & Migration Defaults
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

  # FR-009 Compose Emails
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

  # FR-010 Split Lotto & Draw players
  Scenario: FR-010.S01 Recipients dropdown shows active and expired lotto lists
    Given I am on compose screen
    When I open recipient picker
    Then I see "Lotto players - active" and "Lotto players - expired" and not legacy "Lotto players"

  Scenario: FR-010.S02 Legacy recurring email mapping to active lotto players
    Given a recurring email uses legacy "Lotto players"
    When system loads the recurring config
    Then it is mapped to "Lotto players - active"

  # FR-011 System-Defined Dynamic Recipient List
  Scenario: FR-011 All club contacts system list visible and de-duplicated
    Given club has members, lotto purchasers, shop purchasers, club users, and guardians
    When I open recipient picker
    Then I see read-only list "All club contacts" that aggregates unique contacts from all sources

  # FR-012 Admin Confirmation Email
  Scenario: FR-012.S01 Send confirmation email upon successful import
    Given I have uploaded a CSV that validates to 100% with zero invalid rows
    When the import completes and records are committed
    Then the system sends a confirmation email to the uploader
    And the email is classified as Transactional/Operational and contains non-PII summary

  Scenario: FR-012.S02 Send email on failed or aborted import
    Given the import fails validation or is aborted before commit
    When the process ends
    Then an email is sent to the uploader with relevant (non-PII) information
