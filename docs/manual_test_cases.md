# Manual Test Cases: Bulk Contacts Upload

**Document Version:** 1.0  
**Based on Feature File:** bulk_contacts_upload.feature  
**Date:** 11 March 2026  
**Total Test Cases:** 76

---

## Quick Navigation

- [Happy Path Scenarios](#happy-path-scenarios)
- [FR-001: Access Control](#fr-001-access-control)
- [FR-002: Bulk Import Launcher](#fr-002-bulk-import-launcher)
- [FR-003: CSV Upload & Validation](#fr-003-csv-upload--validation)
  - [File Type Validation](#file-type-validation)
  - [Required Fields Validation](#required-fields-validation)
  - [Email Format Validation](#email-format-validation)
  - [Duplicate Contact Scenarios](#duplicate-contact-scenarios)
  - [Upload Limits](#upload-limits)
  - [Data Normalization](#data-normalization)
- [FR-004: Silent Account Creation](#fr-004-silent-account-creation--verification)
- [FR-005: Lists Management](#fr-005-lists-management)
- [FR-006: Consent Attestation](#fr-006-consent-attestation--myaccount-mapping)
- [FR-007: Send-time Eligibility](#fr-007-send-time-eligibility)
- [FR-008: MyAccount Preferences](#fr-008-myaccount-preferences--migration)
- [FR-009: Compose Emails](#fr-009-compose-emails)
- [FR-010: Lotto System List Split](#fr-010-lotto--draw-players)
- [FR-011: All Club Contacts List](#fr-011-all-club-contacts)
- [FR-012: Admin Confirmation Email](#fr-012-admin-confirmation-email)

---

## Happy Path Scenarios

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-HP-001** | End-to-end successful bulk import workflow | Logged in as Club Admin with permission; Feature flag enabled; Back Office accessible | 1. Navigate to Bulk Import Contacts page<br>2. Upload valid CSV with 100 contacts (95 new, 5 existing)<br>3. System validates file<br>4. On Review step: Check "General club news and club marketing"<br>5. Check "Lotto notifications"<br>6. Select "Create new Static List" and name it "Spring 2026"<br>7. Click "Confirm Import" | 1. File parses with 0 invalid rows<br>2. Advances to Review step<br>3. 95 new accounts created silently<br>4. 95 verification emails sent<br>5. All 100 contacts added to "Spring 2026"<br>6. Audit record captures {uploader_id, timestamp, consent_flags}<br>7. Confirmation email sent to uploader with non-PII summary<br>8. Success message displays with batch ID | **CRITICAL** | CSV: 100 rows (95 new emails, 5 existing system emails); List name: "Spring 2026 Campaign" |
| **TC-HP-002** | Verification and eligibility flow for uploaded contacts | 1. Bulk import completed with 50 new contacts<br>2. All 50 marked "Not verified"<br>3. Test email account with verification inbox accessible | 1. Wait for 30 contacts to click verification link within 24 hours<br>2. Compose Marketing email to "Spring 2026 Campaign"<br>3. Open compose screen<br>4. Select recipient list<br>5. System computes eligibility counts | 1. 30 contacts marked "Verified"<br>2. MyAccount preferences populated: Marketing=Yes, Lotto=Yes<br>3. 30 contacts eligible for Marketing sends<br>4. Compose shows "Matched: 50, Eligible: 30"<br>5. 20 suppressed as unverified<br>6. Only 30 receive email when sent | **CRITICAL** | CSV: 50 new email addresses; Verification links; Marketing email template |
| **TC-HP-003** | Add imported contacts to existing list | 1. Existing list "Loyal Members" contains 200 contacts<br>2. Can access list management | 1. Prepare CSV with 50 new contacts<br>2. Upload CSV<br>3. Select "Add to existing" option<br>4. Choose "Loyal Members" from dropdown<br>5. Complete import | 1. All 50 new contacts added to "Loyal Members"<br>2. "Loyal Members" total = 250 unique contacts<br>3. No duplicates created<br>4. Import completes successfully<br>5. List size updated correctly | **CRITICAL** | CSV: 50 new unique emails; Existing list: "Loyal Members" with 200 contacts |
| **TC-HP-004** | Lotto consent and list management | 1. System has "Active lotto players" system list<br>2. Bulk import flow accessible | 1. Prepare CSV with 75 contacts<br>2. Upload and validate CSV<br>3. On Review: Check "Lotto notifications"<br>4. Select "Add to Active lotto players"<br>5. Complete import with batch ID recorded | 1. All 75 contacts added to "Active lotto players"<br>2. Audit record includes {batch_id, uploader, timestamp, lotto_consent=Yes}<br>3. Upon verification, contacts eligible for lotto results emails<br>4. System does not allow selection of "Lotto players - Expired" without consent | **HIGH** | CSV: 75 contacts; Batch ID: "BATCH-2026-001"; Lotto system list |

---

## FR-001: Access Control

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-AC-001** | Authorized user can access Bulk Import | User logged in as Club Admin with "Bulk import contacts" permission | 1. Open Back Office<br>2. Locate menu/navigation<br>3. Click "Bulk import contacts" entry | 1. "Bulk import contacts" visible as enabled entry<br>2. Bulk Import Contacts main page loads | **HIGH** | User role: Club Admin; Permission: "Bulk import contacts" |
| **TC-AC-002** | Club feature flag disabled hides Bulk Import | 1. User logged in as Club Admin<br>2. Club-level feature flag disabled in admin console | 1. Open Back Office<br>2. Navigate to menu<br>3. Look for Bulk Import option | 1. "Bulk Import" not visible in menu<br>2. OR visible but disabled with tooltip explaining: "Feature not enabled for your club"<br>3. Entry is greyed out | **HIGH** | Club feature flag: "Bulk Import Contacts" = disabled |
| **TC-AC-003** | Permission denied blocks deep link | 1. User logged in as Club Admin<br>2. User lacks "Bulk import contacts" permission | 1. Navigate directly to URL: /bulk-import<br>2. Attempt to interact with page | 1. Page loads but is greyed out/disabled<br>2. All controls non-interactive<br>3. Clear message: "You do not have permission to access this feature"<br>4. No data processing possible | **HIGH** | URL: /bulk-import; User role: Club Admin without permission |

---

## FR-002: Bulk Import Launcher

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-LA-001** | Launcher presents three import types | Authorized user on Bulk Import launcher page | 1. Navigate to Bulk Import launcher<br>2. Observe tiles displayed | 1. Three tiles visible: "Contacts", "Membership registrations", "Lotto playslips"<br>2. Each tile has icon and description<br>3. Tiles are clickable | **HIGH** | None |
| **TC-LA-002** | Contacts tile opens Contacts flow | On Bulk Import launcher page | 1. Click "Contacts" tile | 1. Redirected to "Contacts Upload - Step 1 (CSV Upload & Instructions)"<br>2. Step 1 form displays with upload area<br>3. Instructions visible | **HIGH** | None |
| **TC-LA-003** | Membership tile opens Membership flow | On Bulk Import launcher page | 1. Click "Membership registrations" tile | 1. Redirected to "Membership bulk upload page"<br>2. Membership-specific form loads | **MEDIUM** | None |
| **TC-LA-004** | Playslips tile opens Lotto flow | On Bulk Import launcher page | 1. Click "Playslips" tile | 1. Redirected to "Lotto playslips upload page"<br>2. Lotto-specific form loads | **MEDIUM** | None |

---

## FR-003: CSV Upload & Validation

### File Type Validation

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-FT-001** | Only CSV file type accepted | On Step 1 upload form | 1. Prepare Excel file (.xlsx)<br>2. Attempt to upload<br>3. Check error message<br>4. Repeat with JSON file (.json)<br>5. Repeat with TXT file (.txt) | 1. Excel rejected with error: "Only CSV files are accepted"<br>2. Upload form remains on Step 1<br>3. JSON rejected with same error<br>4. TXT rejected with same error<br>5. All non-CSV files blocked | **HIGH** | Files: test.xlsx, test.json, test.txt |
| **TC-FT-002** | CSV encoding must be UTF-8 compatible | On Step 1 upload form | 1. Upload CSV saved as UTF-8<br>2. Observe result<br>3. Upload CSV with UTF-8 BOM<br>4. Observe result<br>5. Upload CSV with ISO-8859-1 encoding | 1. UTF-8 parsing succeeds<br>2. No encoding errors<br>3. UTF-8 BOM auto-handled (parsed correctly)<br>4. ISO-8859-1 rejected with error: "Unsupported file encoding. Please use UTF-8" | **HIGH** | CSV files with different encodings: UTF-8, UTF-8-BOM, ISO-8859-1 |
| **TC-FT-003** | CSV must have correct header row | On Step 1 upload form | 1. Upload CSV without header (data from row 1)<br>2. Upload CSV with wrong header: "Name, Email, Phone"<br>3. Upload CSV with correct header in row 2 instead of row 1 | 1. No-header CSV rejected: "Header required: First Name, Last Name, Email"<br>2. Wrong-header CSV rejected: "Invalid header. Expected columns: First Name, Last Name, Email"<br>3. Header-in-row-2 CSV rejected: "Header must be in row 1"<br>4. Continue button disabled for all failures | **HIGH** | CSVs: no_header.csv, wrong_header.csv, header_row2.csv |

### Required Fields Validation

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-CSV-001** | Valid CSV advances to Review | CSV file: correct header, all valid rows | 1. Navigate to Step 1<br>2. See instruction: "Columns A/B/C = First Name / Last Name / Email (header required)"<br>3. Upload valid CSV | 1. File parses successfully<br>2. Advances to Review step<br>3. 0 invalid rows displayed<br>4. "Continue" button enabled | **CRITICAL** | CSV: valid_contacts.csv (header + 10 valid rows) |
| **TC-CSV-002** | Missing header row blocks parse | CSV file without header row | 1. On Step 1<br>2. Upload CSV without header<br>3. Observe error and button state | 1. Inline error shown: "Header required: First Name, Last Name, Email"<br>2. Continue button remains disabled<br>3. Form prevents proceeding | **HIGH** | CSV: no_header.csv |
| **TC-VAL-001** | Required field blank: First Name | CSV with blank First Name in row 2 | 1. Upload CSV<br>2. System validates<br>3. Check row 2 status | 1. Row 2 marked "Invalid"<br>2. Reason shows: "First name is required"<br>3. Continue button disabled | **HIGH** | CSV with row: [blank] | Smith | john@club.ie |
| **TC-VAL-002** | Required field blank: Last Name | CSV with blank Last Name in row 4 | 1. Upload CSV<br>2. System validates<br>3. Check row 4 status | 1. Row 4 marked "Invalid"<br>2. Reason shows: "Last name is required"<br>3. Continue blocked | **HIGH** | CSV with row: John | [blank] | john@club.ie |
| **TC-VAL-003** | Required field blank: Email | CSV with blank Email in row 10 | 1. Upload CSV<br>2. System validates<br>3. Check row 10 status | 1. Row 10 marked "Invalid"<br>2. Reason shows: "Email is required"<br>3. Continue blocked | **HIGH** | CSV with row: John | Smith | [blank] |
| **TC-VAL-004** | Multiple blank fields in single row | CSV row 5: First Name blank, Email blank | 1. Upload CSV<br>2. System validates row 5 | 1. Row 5 marked "Invalid"<br>2. Error message shows: "First name is required, Email is required"<br>3. All missing fields listed | **MEDIUM** | CSV with row 5: [blank] | Smith | [blank] |
| **TC-VAL-005** | All required fields blank | CSV row 8: all fields blank | 1. Upload CSV<br>2. System validates row 8 | 1. Row 8 marked "Invalid"<br>2. Error shows: "First name is required, Last name is required, Email is required" | **HIGH** | CSV with row 8: [blank] | [blank] | [blank] |

### Email Format Validation

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-EMAIL-001** | Invalid email: double @@ | CSV row 2: alice@@domain.com | 1. Upload CSV<br>2. System validates | 1. Row 2 marked "Invalid"<br>2. Reason: "Invalid email format"<br>3. Continue blocked | **HIGH** | Email: alice@@domain.com |
| **TC-EMAIL-002** | Invalid email: missing @ | CSV row 4: bob.domain.com | 1. Upload CSV<br>2. System validates | 1. Row 4 marked "Invalid"<br>2. Reason: "Invalid email format"<br>3. Continue blocked | **HIGH** | Email: bob.domain.com |
| **TC-EMAIL-003** | Invalid email: missing TLD | CSV row 10: charlie@domain | 1. Upload CSV<br>2. System validates | 1. Row 10 marked "Invalid"<br>2. Reason: "Invalid email format"<br>3. Continue blocked | **HIGH** | Email: charlie@domain |
| **TC-EMAIL-004** | Valid email edge cases | CSV with: user+tag@example.com, user.name@example.co.uk, user_name@example.com, user@sub.domain.example.io | 1. Upload CSV<br>2. System validates all rows | 1. All rows marked valid<br>2. System accepts+ signs, dots, underscores, subdomains<br>3. Advance to Review | **MEDIUM** | Emails: user+tag@example.com, user.name@example.co.uk, user_name@example.com, user@sub.domain.example.io |
| **TC-EMAIL-005** | Invalid email edge cases | CSV with: user@, @example.com, user@.com, user name@example.com | 1. Upload CSV<br>2. System validates | 1. All rows marked "Invalid"<br>2. Reason: "Invalid email format" for each<br>3. Continue blocked<br>4. No partial acceptance | **MEDIUM** | Emails: user@, @example.com, user@.com, user name@example.com (all invalid) |

### Duplicate Contact Scenarios

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-DUP-001** | In-file duplicate emails (same CSV) | CSV with email "johndoe@club.ie" on rows 2 and 5 | 1. Upload CSV<br>2. System validates<br>3. Check rows 2 and 5 | 1. Row 2 kept as canonical record<br>2. Row 5 flagged: "Duplicate in file (ignored)"<br>3. Proceed allowed (if no other invalids)<br>4. Only 1 record processed | **HIGH** | CSV with duplicate email on rows 2, 5: johndoe@club.ie |
| **TC-DUP-002** | Multiple in-file duplicates | CSV with email "alice@club.ie" on rows 2, 5, 9 | 1. Upload CSV<br>2. System validates | 1. Row 2 kept (canonical)<br>2. Rows 5, 9 flagged: "Duplicate in file (ignored)"<br>3. Summary shows: "2 duplicates ignored; 1 record processed"<br>4. Proceed allowed | **HIGH** | CSV with alice@club.ie on rows 2, 5, 9 |
| **TC-DUP-003** | Existing account suppression (system duplicate) | System has account: existing.user@club.ie; CSV row 3 contains same email | 1. Upload CSV<br>2. System validates<br>3. Check row 3 | 1. Row 3 shows Warning: "Existing account found for existing.user@club.ie"<br>2. Row marked valid (not invalid)<br>3. Proceed allowed | **MEDIUM** | System account: existing.user@club.ie; CSV: same email |
| **TC-DUP-004** | Existing account with name mismatch (soft-merge) | System account: Email=johndoe@club.ie, First=John, Last=Doe; CSV: Email=johndoe@club.ie, First=Johnny | 1. Upload CSV<br>2. Validate<br>3. Check row status<br>4. Complete import<br>5. Verify result | 1. Row shows Warning: "Name mismatch with existing account. First name and last name will be updated from this account upon upload"<br>2. Row marked valid<br>3. Upon import completion, existing name remains: John Doe<br>4. No update applied<br>5. Batch record notes existing account | **MEDIUM** | System: john@club.ie (John Doe); CSV: john@club.ie (Johnny Doe) |
| **TC-DUP-005** | Case-insensitive email deduplication | CSV rows: John@Club.IE (row 2), john@club.ie (row 5) | 1. Upload CSV<br>2. System validates | 1. Row 2 kept as canonical<br>2. Row 5 flagged: "Duplicate in file (ignored)"<br>3. System recognizes both as same email (case-insensitive) | **HIGH** | Emails: John@Club.IE, john@club.ie |
| **TC-DUP-006** | Email with whitespace trimming (dedup) | CSV rows: john@club.ie (row 2), " john@club.ie " (row 5 with spaces) | 1. Upload CSV<br>2. System validates | 1. Row 5 whitespace trimmed to "john@club.ie"<br>2. Row 5 flagged as duplicate of row 2<br>3. Both recognized as same email after normalization<br>4. Row 2 kept, row 5 ignored | **HIGH** | Emails: john@club.ie, [space]john@club.ie[space] |

### Upload Limits

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-LIMIT-001** | Row count limit exceeded | CSV with 1001 rows (row cap: 1000) | 1. Upload CSV<br>2. System attempts parse | 1. Parsing blocked<br>2. Error: "File exceeds maximum row count (1001 rows, limit is 1000)"<br>3. No partial processing<br>4. Continue button disabled | **HIGH** | CSV: 1001 data rows |
| **TC-LIMIT-002** | Exact row count limit accepted | CSV with exactly 1000 data rows | 1. Upload CSV<br>2. System parses | 1. File parses successfully<br>2. Validation proceeds normally<br>3. All rows processed<br>4. Advance to Review | **HIGH** | CSV: 1000 data rows (exactly) |
| **TC-LIMIT-003** | One row below limit accepted | CSV with 999 data rows | 1. Upload CSV<br>2. System parses | 1. File parses successfully<br>2. Validation proceeds<br>3. All rows processed | **MEDIUM** | CSV: 999 data rows |
| **TC-LIMIT-004** | File size limit exceeded | CSV file: 10.5 MB (size cap: 10 MB) | 1. Upload CSV<br>2. System checks size | 1. Parsing blocked<br>2. Error: "File exceeds maximum size (10.5 MB, limit is 10 MB)"<br>3. No partial processing<br>4. Continue disabled | **HIGH** | CSV: >10 MB file size |
| **TC-LIMIT-005** | Exact file size limit accepted | CSV file: exactly 10 MB | 1. Upload CSV<br>2. System checks size | 1. File parses successfully<br>2. Validation proceeds | **HIGH** | CSV: 10.0 MB (exactly) |
| **TC-LIMIT-006** | Row & size limits: both exceeded | CSV: 1500 rows, 12 MB size | 1. Upload CSV<br>2. System validates | 1. Parsing blocked<br>2. Error mentions both limits exceeded<br>3. Both limits shown in error message<br>4. Continue disabled | **HIGH** | CSV: 1500 rows, 12 MB |
| **TC-LIMIT-007** | Performance: validation within 10 seconds | CSV: 1000 valid rows | 1. Upload CSV<br>2. Start timer<br>3. Observe validation | 1. Validation completes within 10 seconds<br>2. Progress indicator shown<br>3. UI remains responsive<br>4. No blocking<br>5. Results displayed | **MEDIUM** | CSV: 1000 valid rows |

### Data Normalization

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-NORM-001** | Whitespace trimming in all fields | CSV: row 3 = " John " | " Doe " | " john@club.ie " | 1. Upload CSV<br>2. System validates | 1. Row trimmed to: "John" | "Doe" | "john@club.ie"<br>2. Row marked valid (if other rules pass)<br>3. No whitespace preserved | **MEDIUM** | Row: " John " | " Doe " | " john@club.ie " |
| **TC-NORM-002** | Email canonicalization for matching | CSV with emails: "JOHN@CLUB.IE", "John@Club.IE", "john@club.ie" | 1. Upload CSV<br>2. System validates | 1. All canonicalized to lowercase "john@club.ie"<br>2. Two marked as duplicates of first<br>3. Case-insensitive matching confirmed | **HIGH** | Emails in mixed case: JOHN@CLUB.IE, John@Club.IE, john@club.ie |
| **TC-NORM-003** | Special characters and accents preserved | CSV: François Müller; Jean-Paul O'Brien | 1. Upload CSV<br>2. System validates<br>3. Check result | 1. Special characters preserved: François, Müller, Jean-Paul, O'Brien<br>2. Rows marked valid<br>3. Data stored correctly | **MEDIUM** | Names: François, Müller, Jean-Paul, O'Brien |
| **TC-NORM-004** | No downloadable error file; re-upload required | CSV with 25 invalid rows | 1. Upload CSV with many invalids<br>2. Check Step 1 UI<br>3. Look for error download option | 1. All invalid rows displayed inline with reasons<br>2. Message shows: "Please correct these rows in your source file and re-upload"<br>3. NO "Download error report" button<br>4. Manual fix and re-upload required | **MEDIUM** | CSV with 25 invalid rows |

---

## FR-004: Silent Account Creation & Verification

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-ACC-001** | Create account and send verification for new email | CSV row 2: email "new@club.ie" (not in system) | 1. Upload and validate CSV<br>2. On Review step, attest consent<br>3. Select list<br>4. Confirm import<br>5. Wait for processing | 1. Account created silently for "new@club.ie"<br>2. Verification email sent to "new@club.ie"<br>3. Contact marked "Not verified"<br>4. Ineligible for non-transactional sends<br>5. No user notification except verification email | **CRITICAL** | Email: new@club.ie (new to system) |
| **TC-ACC-002** | Existing email does not receive notification | CSV row 3: email "existing@club.ie" (already has account) | 1. Upload CSV<br>2. System validates<br>3. Complete import | 1. No verification email sent<br>2. No notification to existing@club.ie<br>3. Row accepted (if name matches)<br>4. Import completes without alert | **HIGH** | System account: existing@club.ie; CSV: same email |
| **TC-ACC-003** | Login-based resend verification (nice to have) | New unverified contact with valid password | 1. Attempt to log in<br>2. Check for resend option<br>3. Click resend<br>4. Check new token | 1. Login blocked or prompted<br>2. "Resend verification" option visible<br>3. Click triggers fresh verification email<br>4. Prior token invalidated<br>5. New token in email valid | **MEDIUM** | Unverified account; Valid password |
| **TC-ACC-004** | Hard bounce marks UNDELIVERABLE | Verification email bounces hard (ESP webhook) | 1. Simulate hard bounce via ESP<br>2. Webhook received by system<br>3. Check contact record<br>4. Attempt to send future email | 1. Contact marked UNDELIVERABLE<br>2. Future sends suppress contact<br>3. Suppression reason: UNDELIVERABLE<br>4. Contact cannot receive any non-transactional mail | **HIGH** | Contact: bad@club.ie; Hard bounce signal |
| **TC-ACC-005** | Verification completion unlocks eligibility | Contact previously Not verified | 1. Contact clicks verification link<br>2. Complete verification<br>3. Check status<br>4. Attempt to send marketing email | 1. Status changed to "Verified"<br>2. Contact eligible for Marketing sends (subject to consent)<br>3. Can receive emails matching consent rules<br>4. Send-time eligibility unlocked | **HIGH** | Verification link; Marketing send trigger |
| **TC-ACC-006** | Per-upload toggle defaults ON: send account created email | On Import Options: "Send 'account created' email" visible and ON | 1. Navigate to Options<br>2. Toggle is ON (default)<br>3. Complete import that creates 25 new accounts<br>4. Check email logs | 1. Toggle visible and enabled<br>2. Both "account created" AND verification emails sent<br>3. New contacts receive 2 emails<br>4. Existing contacts receive no emails<br>5. Email logs show 25 account-created + 25 verification | **MEDIUM** | 25 new accounts; Toggle state: ON |
| **TC-ACC-007** | Turning toggle OFF: skip account created email | On Import Options: Toggle visible and ON | 1. Locate toggle<br>2. Switch toggle to OFF<br>3. Complete import with 10 new accounts<br>4. Check email logs | 1. Account created email NOT sent<br>2. Verification email IS sent (10 total)<br>3. New contacts receive 1 email (verification only)<br>4. No account creation notifier<br>5. Existing accounts still not contacted | **MEDIUM** | 10 new accounts; Toggle state: OFF |

---

## FR-005: Lists Management

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-LS-001** | Create Static List at upload | On Review step | 1. Select "Create new Static List"<br>2. Enter name: "2026 Diaspora"<br>3. Complete 100% valid import | 1. Static list "2026 Diaspora" created<br>2. All imported contacts added<br>3. List available in compose dropdown<br>4. Can target in future sends | **HIGH** | List name: "2026 Diaspora"; Contact count: all from import |
| **TC-LS-002** | Add to existing Static List | Existing list "Life members" has 200 contacts; 50 new contacts imported, some already in "Life members" | 1. Select "Add to existing"<br>2. Choose "Life members"<br>3. Complete import | 1. Only new (not already in list) added<br>2. No duplicate list entries<br>3. List size = 200 + new (not duplicated)<br>4. Import completes successfully<br>5. List deduplication works | **HIGH** | List: "Life members" (200 existing); Import: 50 new |
| **TC-LS-003** | Add to Active/Expired lotto lists with consent | Lotto consent attested; Step 2 showing list options | 1. Check "Lotto notifications" consent<br>2. Select "Active lotto players" from list dropdown<br>3. Complete import | 1. All imported contacts added to "Active lotto players"<br>2. "Lotto players - Expired" NOT selectable/visible<br>3. Consent enforcement confirms only Active available | **HIGH** | Consent: Lotto=Yes; List: "Active lotto players" |
| **TC-LS-004** | Block adding to lotto lists without consent | Lotto consent NOT attested on Review step | 1. Do NOT check "Lotto notifications"<br>2. Attempt to select "Active lotto players"<br>3. Submit or click | 1. Selection blocked<br>2. Explanatory message shown: "Lotto consent required to add to lotto lists"<br>3. Option greyed out or disabled<br>4. Cannot proceed with lotto list selection | **HIGH** | Consent: Lotto=No; List selection: "Active lotto players" |

---

## FR-006: Consent Attestation & MyAccount Mapping

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-CA-001** | Immediate audit record on attestation | On Import Options step | 1. Check "General club news and club marketing consent"<br>2. Check "Lotto result notifications"<br>3. Confirm and proceed past Options | 1. Audit record written immediately<br>2. Contains: uploader_id, timestamp, file_name, consent_flags<br>3. Record persisted to audit log<br>4. Queryable for compliance | **HIGH** | User: admin@club.ie; Consents: Both checked; Timestamp: recorded |
| **TC-CA-002** | Map attested consent after verification | Import with "paul@club.ie"; attestation: Marketing=Yes, Lotto=Yes; contact is Not verified | 1. Import batch with consents<br>2. Contact "paul@club.ie" verifies email<br>3. Check MyAccount preferences | 1. MyAccount populated after verification<br>2. Marketing = Yes (from attestation)<br>3. Lotto = Yes (from attestation)<br>4. Preferences visible under club<br>5. Auto-populated only when unset | **HIGH** | Email: paul@club.ie; Consents: Both Yes |
| **TC-CA-003** | Defaults with no attestation | Import with NO consent checkboxes ticked | 1. Complete import without attestation<br>2. Contacts verify<br>3. Check MyAccount | 1. Marketing set to "Unset"<br>2. Lotto set to "Unset"<br>3. No default enrollment<br>4. User later sets own preferences | **MEDIUM** | Consents: None checked |
| **TC-CA-004** | Do not override existing preferences | Contact "ben@club.ie" has existing: Marketing=No, Lotto=Yes; Import attests: Marketing=Yes, Lotto=Yes | 1. Complete import with attestation<br>2. Contact verifies (if new)<br>3. Check MyAccount | 1. Ben's existing Marketing = No (NOT overridden)<br>2. Ben's Lotto = Yes (unchanged)<br>3. Batch attestation does NOT overwrite user-set prefs<br>4. User authority respected | **CRITICAL** | Email: ben@club.ie; Existing: Marketing=No, Lotto=Yes; Attestation: Both Yes |
| **TC-CA-005** | Mixed batch: set and unset preferences | Batch with Ciara (no prefs set) and Dan (Marketing=Yes, Lotto=No) | 1. Upload batch with Marketing=Yes attestation<br>2. Both verify<br>3. Check each MyAccount | 1. Ciara: Marketing=Yes, Lotto=Yes populated from attestation<br>2. Dan: Marketing=Yes (unchanged), Lotto=No (unchanged)<br>3. Each rule applied per-contact<br>4. No batch-wide override | **HIGH** | Ciara: new (unset); Dan: existing (set prefs) |

---

## FR-007: Send-time Eligibility

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-SEND-001** | Marketing eligibility rules | Contacts with various states: Verified/Unverified, Marketing Yes/No/Unset | 1. Compose Marketing email<br>2. System computes eligibility<br>3. Review counts | 1. Only contacts with Verified=true AND Marketing=Yes eligible<br>2. Unverified suppressed<br>3. Marketing=No suppressed<br>4. Marketing=Unset suppressed<br>5. Counts reconcile: Matched = Eligible + Suppressed | **CRITICAL** | Mixed contacts; Classification: Marketing |
| **TC-SEND-002** | Transactional bypass for receipts/password/welcome | Transactional email (receipt) | 1. Compose Transactional email<br>2. System computes eligibility<br>3. Check suppression | 1. Marketing consent NOT enforced<br>2. Verified/Unverified status checked per channel<br>3. More contacts eligible than Marketing send<br>4. Suppression reasons different (if any) | **HIGH** | Email type: Transactional (receipt) |
| **TC-SEND-003** | Lotto results allowed when Lotto consent exists | Contacts with Lotto=Yes (from import attestation) | 1. Send Lotto results email<br>2. System evaluates recipients<br>3. Check eligibility | 1. Contacts with Lotto consent eligible<br>2. List membership + consent checked<br>3. Eligible contacts receive lotto email<br>4. Proper targeting applied | **HIGH** | Email type: Lotto results; Consent: Lotto=Yes |
| **TC-SEND-004** | Platform-wide unverified suppression | Any unverified account holder | 1. Compose non-transactional email<br>2. Unverified contact included<br>3. Send email | 1. Unverified contact suppressed<br>2. Suppression reason: UNVERIFIED<br>3. Applies to all non-transactional sends<br>4. Regardless of origin (imported or not) | **CRITICAL** | Contact: Verified=false; Email: non-transactional |

---

## FR-008: MyAccount Preferences & Migration

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-MP-001** | Migration defaults for existing Email=Yes | Pre-release: Account holder with Email=Yes | 1. System releases update<br>2. Check account holder MyAccount | 1. "General club news and club marketing" = Yes (mapped)<br>2. Preference visible in MyAccount<br>3. One-time migration applied<br>4. User can later change | **HIGH** | Existing account; Email=Yes pre-release |
| **TC-MP-002** | Migration sets Lotto=Yes for lotto entrants | Pre-release: Account holder with lotto ticket purchase history | 1. System releases update<br>2. Check account holder MyAccount | 1. Lotto notifications = Yes (auto-set)<br>2. Applied to all clubs where lotto ticket purchased<br>3. Per-club preference populated | **HIGH** | Account with lotto purchase history |
| **TC-MP-003** | User updates per-club preferences | Verified user in MyAccount | 1. Navigate to MyAccount<br>2. Select club<br>3. Check preferences<br>4. Change Marketing=Yes, Lotto=Yes<br>5. Save<br>6. Send email | 1. Preferences updated immediately<br>2. Changes persisted<br>3. Next send eligibility respects new prefs<br>4. User authority maintained<br>5. Contact receives email (if eligible per new rules) | **HIGH** | User preferences: updatable; Send test = email delivered |

---

## FR-009: Compose Emails

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-CMP-001** | Default classification to Marketing; show counts | Open compose email form | 1. Select recipient list<br>2. System computes counts<br>3. Check classification<br>4. View summary | 1. Classification defaults to "Marketing"<br>2. Summary shows: "Matched: X, Eligible: Y for marketing"<br>3. Counts displayed clearly<br>4. Eligible ≤ Matched (suppressed = difference) | **HIGH** | List: Static or system; Email: once-off or recurring |
| **TC-CMP-002** | Deduplicate recipients across lists | Select 2+ lists with overlapping recipients | 1. Select list 1 and list 2 (with overlap)<br>2. System computes<br>3. Check counts | 1. Matched = unique deduplicated emails<br>2. No contact counted twice<br>3. Eligible computed from dedup set<br>4. Targeting sends to each contact once | **HIGH** | Lists: "Supporters 2026" + "Members" (with overlap) |
| **TC-CMP-003** | Transactional override requires confirmation | Classification = Marketing; Matched > Eligible | 1. Review eligibility counts<br>2. Check confirmation checkbox: "I confirm this email is not marketing..."<br>3. Click Send | 1. Checkbox required for send<br>2. Without check, Send button disabled<br>3. Classification changes to Transactional<br>4. Send proceeds to all matched (except UNDELIVERABLE)<br>5. Audit logs override confirmation | **HIGH** | Checkbox: required; Classification: Transactional (after override) |
| **TC-CMP-004** | Recurring emails re-evaluate at send time | Recurring email scheduled weekly | 1. Schedule recurring email<br>2. Wait for scheduled send<br>3. Check eligibility before send<br>4. Send executes | 1. At each scheduled time, system recomputes Matched/Eligible<br>2. Current data used (not snapshot)<br>3. Suppressed reasons re-evaluated<br>4. Email sent to current-eligible only<br>5. Preferences/verification status changes honored | **HIGH** | Recurring: weekly; Schedule: run test |

---

## FR-010: Lotto & Draw Players

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-LOT-001** | Recipients dropdown shows Active/Expired, not legacy | Compose email screen open | 1. Open recipient picker<br>2. Scroll system lists<br>3. Check for lotto options | 1. "Lotto players - active" visible<br>2. "Lotto players - expired" visible<br>3. Legacy "Lotto players" NOT shown<br>4. Both new lists selectable | **HIGH** | System lists available |
| **TC-LOT-002** | Legacy recurring email mapping to active | Recurring email using legacy "Lotto players" | 1. Open recurring email config<br>2. Load email<br>3. Check recipient selection | 1. System maps to "Lotto players - active"<br>2. UI displays "Lotto players - active"<br>3. Legacy label not shown<br>4. Recurring continues to work | **MEDIUM** | Legacy email config |

---

## FR-011: All Club Contacts

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-ACC-SYS-001** | All club contacts system list visible and deduplicated | Recipient picker open; club has members, lotto, 50/50, shop, users, guardians | 1. Open recipient picker<br>2. Scroll to system lists<br>3. Check "All club contacts"<br>4. Select and compose<br>5. Send | 1. "All club contacts" visible (read-only)<br>2. Includes all sources: membership, lotto, 50/50, shop, club users, guardians<br>3. Deduplicated unique contacts<br>4. Each contact receives email once<br>5. Cannot be edited/deleted | **HIGH** | System list: "All club contacts" |

---

## FR-012: Admin Confirmation Email

| TC-ID | Scenario | Precondition | Steps | Expected Result | Priority | Test Data |
|-------|----------|--------------|-------|-----------------|----------|-----------|
| **TC-ADM-001** | Send confirmation email upon successful import | Import completed; records committed; uploader email accessible | 1. Complete import with 0 invalid rows<br>2. Confirm at Step 3<br>3. System processes<br>4. Check uploader inbox | 1. Confirmation email sent to uploader account email<br>2. Subject line shows import summary<br>3. Email classified as Transactional/Operational<br>4. Non-PII summary included:<br>&nbsp;&nbsp;- Club name<br>&nbsp;&nbsp;- Uploader name/email<br>&nbsp;&nbsp;- Datetime<br>&nbsp;&nbsp;- Batch ID<br>&nbsp;&nbsp;- Rows processed count<br>&nbsp;&nbsp;- New accounts created<br>&nbsp;&nbsp;- Existing accounts matched<br>&nbsp;&nbsp;- Verification emails sent<br>5. No individual contact emails in body | **CRITICAL** | Uploader: admin@club.ie; Batch: BATCH-2026-001 |
| **TC-ADM-002** | Send email on failed or aborted import | Import fails validation or user aborts before Step 3 commit | 1. Upload CSV with errors OR<br>2. Abort during Step 2<br>3. Process ends<br>4. Check uploader inbox | 1. Email still sent to uploader<br>2. Subject/content explains failure/abort<br>3. Relevant non-PII information included<br>4. Resolution steps provided<br>5. Email classified as Transactional | **HIGH** | Failed import or abort scenario |

---

## Test Execution Summary

### Test Distribution by Priority

| Priority | Count | Examples |
|----------|-------|----------|
| **CRITICAL** | 8 | TC-HP-001, TC-CSV-001, TC-ACC-001, TC-CA-004, TC-SEND-001, TC-SEND-004, TC-ADM-001 |
| **HIGH** | 48 | Most FR-specific scenarios, access control, validation, duplicates, limits |
| **MEDIUM** | 20 | Edge cases, normalization, lotto advanced, preferences, performance |

### Key Test Modules

- **Access Control:** 3 tests
- **File Validation:** 16 tests (file type, encoding, header, fields, email, duplicates, limits)
- **Account Management:** 7 tests
- **Lists:** 4 tests
- **Consent Mapping:** 5 tests
- **Send-time Rules:** 4 tests
- **MyAccount:** 3 tests
- **Compose:** 4 tests
- **System Lists:** 5 tests
- **Admin Notifications:** 2 tests

### Recommended Test Order

1. **Phase 1 (Access & Foundation):** TC-AC-001 to TC-AC-003, TC-LA-001 to TC-LA-004
2. **Phase 2 (CSV Validation):** TC-FT-001 to TC-FT-003, TC-CSV-001 to TC-CSV-002, TC-VAL-001 to TC-VAL-005
3. **Phase 3 (Duplicates & Limits):** TC-DUP-001 to TC-DUP-006, TC-LIMIT-001 to TC-LIMIT-007
4. **Phase 4 (Data Processing):** TC-ACC-001 to TC-ACC-007, TC-LS-001 to TC-LS-004
5. **Phase 5 (Consent & Eligibility):** TC-CA-001 to TC-CA-005, TC-SEND-001 to TC-SEND-004
6. **Phase 6 (Advanced Features):** TC-CMP-001 to TC-CMP-004, TC-LOT-001 to TC-LOT-002, TC-ADM-001 to TC-ADM-002

---

**End of Manual Test Cases**

**Document Classification:** Internal – QA  
**Last Updated:** 11 March 2026  
**Status:** Ready for QA Execution
