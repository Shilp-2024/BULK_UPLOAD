# Bulk Contacts Upload — Specification

## Overview
This specification is derived from the Gherkin feature `features/bulk_contacts_upload.feature` and documents functional requirements, scenarios, preconditions, steps and expected outcomes for the Bulk Contacts Upload feature.

Background (applies to scenarios unless overridden):
- Signed in as a Club Admin with the "Bulk import contacts" permission
- Club-level feature flag for Bulk Import Contacts is enabled

---

## FR-001 Access & Launcher

- ID: FR-001.S01
  - Title: Authorized user can access Bulk Import
  - Preconditions: Club admin with permission, feature flag enabled
  - Steps: Open Back Office → Click "Bulk import contacts"
  - Expected: "Bulk import contacts" visible/enabled; lands on main page

- ID: FR-001.S02
  - Title: Club feature flag disabled hides Bulk Import
  - Preconditions: Feature flag disabled
  - Steps: Open Bulk import side menu
  - Expected: "Bulk Import" not visible or disabled with tooltip

- ID: FR-001.S03
  - Title: Permission denied blocks deep link
  - Preconditions: Club admin without permission
  - Steps: Navigate to `/bulk-import`
  - Expected: Page greyed out and not selectable

---

## FR-002 Bulk Import Launcher

- ID: FR-002.S01
  - Title: Launcher presents three import types
  - Steps: Land on Bulk Import launcher
  - Expected: Tiles for "Contacts", "Membership registrations", "Lotto playslips"

- ID: FR-002.S02
  - Title: Contacts tile opens Contacts flow
  - Steps: Click "Contacts"
  - Expected: Land on Contacts Upload - Step 1

- ID: FR-002.S03
  - Title: Membership tile opens Membership flow
  - Steps: Click "Membership registrations"
  - Expected: Land on Membership bulk upload page

- ID: FR-002.S04
  - Title: Playslips tile opens Lotto flow
  - Steps: Click "Playslips"
  - Expected: Land on Lotto playslips upload page

---

## FR-003 CSV Upload & Validation

- ID: FR-003.S01
  - Title: Valid CSV advances to Review
  - Preconditions: On Step 1; instruction visible
  - Steps: Upload CSV with correct header and valid rows
  - Expected: Parses successfully; advances with 0 invalid rows

- ID: FR-003.S02
  - Title: Missing header row blocks parse
  - Steps: Upload CSV without header
  - Expected: Inline error "Header required: First Name, Last Name, Email"; continue disabled

- ID: FR-003.S03 (outline)
  - Title: Required field blank marks row invalid
  - Examples: Row 2 First name; Row 4 Last name; Row 10 Email
  - Expected: Row marked Invalid; reason "<Field> is required"; continue blocked until resolved

- ID: FR-003.S04 (outline)
  - Title: Invalid email format marks row invalid
  - Examples: invalid email patterns
  - Expected: Row marked Invalid with reason "Invalid email format"; continue blocked

- ID: FR-003.S05
  - Title: In-file duplicate emails are ignored after first
  - Steps: Upload CSV with repeated email on rows 2 and 5
  - Expected: Row 2 kept; row 5 flagged "Duplicate in file (ignored)"; may proceed if no other invalids

- ID: FR-003.S06
  - Title: Existing account + name mismatch handling (soft-merge)
  - Preconditions: Existing account for email with different name
  - Steps: Upload CSV and validate
  - Expected: Warning shown; on commit, existing account name remains authoritative

- ID: FR-003.S07
  - Title: File caps exceeded block parse
  - Preconditions: Row cap 5000, size cap 10 MB
  - Steps: Upload CSV > caps
  - Expected: Parsing blocked with explicit error; no partial processing

- ID: FR-003.S08
  - Title: No inline error file; re-upload required
  - Expected: UI informs user to correct source file and re-upload

- ID: FR-003.S09
  - Title: Encoding and whitespace normalization
  - Steps: Upload CSV with trailing spaces/mixed case
  - Expected: Trim whitespace; canonicalisation applied to names/emails

---

## FR-004 Silent Account Creation & Verification

- ID: FR-004.S01
  - Title: Create account and send verification for new email
  - Steps: Complete validated import with new email
  - Expected: Silent account created; verification sent; Not verified and ineligible for non-transactional sends

- ID: FR-004.S02
  - Title: Existing email does not receive a notification
  - Steps: Complete import with existing email
  - Expected: No verification sent; row accepted if name rules met

- ID: FR-004.S03
  - Title: Login-based resend verification (nice to have)
  - Expected: Unverified user with password sees "Resend verification"; clicking sends fresh token and invalidates prior

- ID: FR-004.S04
  - Title: Hard bounce marks UNDELIVERABLE
  - Steps: ESP webhook indicates bounce
  - Expected: Deliverability set false; suppression reason UNDELIVERABLE applied

- ID: FR-004.S05
  - Title: Verification completion unlocks eligibility
  - Steps: User completes verification
  - Expected: Status Verified; eligible for Marketing sends subject to consent

- ID: FR-004.S06
  - Title: Per-upload toggle defaults ON to send 'account created' email
  - Steps: Toggle ON (default) → complete import creating 25 accounts
  - Expected: 'Account created' + verification emails sent to new accounts

- ID: FR-004.S07
  - Title: Turning the toggle OFF skips the 'account created' email but still sends verification
  - Steps: Toggle OFF → complete import creating new accounts
  - Expected: No 'account created' email; verification emails are sent

---

## FR-005 Lists (Static & Lotto)

- ID: FR-005.S01
  - Title: Create Static List at upload
  - Steps: Choose Create new Static List, name it; complete 100% valid import
  - Expected: Imported contacts added to the new list

- ID: FR-005.S02
  - Title: Add to existing Static List
  - Steps: Select an existing list and import
  - Expected: Only missing contacts added; no duplicate list creation

- ID: FR-005.S03
  - Title: Add to Active/Expired lotto lists with consent
  - Preconditions: Lotto consent attested for batch
  - Steps: Select "Active lotto players"
  - Expected: Contacts added to Active list; expired list not selectable

- ID: FR-005.S04
  - Title: Block adding to lotto lists without consent
  - Steps: No lotto consent ticked and attempt to select lotto list
  - Expected: Selection blocked with explanatory message

---

## FR-006 Consent Attestation & MyAccount Mapping

- ID: FR-006.S01
  - Title: Immediate audit on attestation
  - Steps: Tick consent boxes on Import Options and confirm
  - Expected: Audit record with uploader id, timestamp, file and consent flags

- ID: FR-006.S02
  - Title: Map attested consent after verification
  - Preconditions: Contact in attested batch is Not verified
  - Steps: Contact verifies
  - Expected: MyAccount per-club preferences set from attestation (Marketing=Yes, Lotto=Yes)

- ID: FR-006.S03
  - Title: Defaults with no attestation
  - Expected: Upon verification, Marketing and Lotto set to Unset

- ID: FR-006.S07
  - Title: Do not override existing preferences
  - Steps: Batch attests Yes when contact has existing preferences
  - Expected: Existing preferences remain unchanged

- ID: FR-006.S08
  - Title: Mixed batch with set and unset preferences
  - Expected: Only unset preferences populated from attestation upon verification

---

## FR-007 Send-time Eligibility & Unverified Suppression

- ID: FR-007.S01
  - Title: Marketing eligibility rules
  - Steps: Compose a marketing email
  - Expected: Only contacts with Verified = true AND Marketing = Yes receive the email

- ID: FR-007.S02
  - Title: Transactional bypass for receipts/password/welcome
  - Expected: Transactional sends bypass Marketing consent (subject to channel verification rules)

- ID: FR-007.S03
  - Title: Lotto results allowed when Lotto consent exists
  - Expected: Contacts with Lotto consent eligible for lotto results emails

- ID: FR-007.S04
  - Title: Platform-wide unverified suppression
  - Expected: Unverified accounts suppressed for non-transactional sends with reason UNVERIFIED

---

## FR-008 MyAccount Preferences & Migration Defaults

- ID: FR-008.S01
  - Title: Migration defaults for existing Email=Yes
  - Expected: Existing Email=Yes becomes General club news and club marketing = Yes

- ID: FR-008.S02
  - Title: Migration sets Lotto=Yes for historical lotto entrants
  - Expected: Per-club Lotto notifications = Yes

- ID: FR-008.S03
  - Title: User updates per-club preferences
  - Expected: Subsequent eligibility checks include updated preferences

---

## FR-009 Compose Emails

- ID: FR-009.S01
  - Title: Default to Marketing and show counts
  - Expected: Classification defaults to Marketing; Counts show Matched vs Eligible

- ID: FR-009.S02
  - Title: Deduplicate recipients across lists
  - Expected: Matched reflects deduplicated unique emails and Eligible computed accordingly

- ID: FR-009.S05
  - Title: Transactional override requires explicit confirmation
  - Steps: Check confirmation checkbox when Matched > Eligible
  - Expected: Classification set to Transactional for this send only

- ID: FR-009.S06
  - Title: Recurring emails re-evaluate at send time
  - Expected: Each occurrence recomputes Matched/Eligible/Suppressed using current data

---

## FR-010 Split Lotto & Draw players

- ID: FR-010.S01
  - Title: Recipients dropdown shows active and expired lotto lists
  - Expected: "Lotto players - active" and "Lotto players - expired" visible; legacy list not shown

- ID: FR-010.S02
  - Title: Legacy recurring email mapping to active lotto players
  - Expected: Legacy "Lotto players" mapped to "Lotto players - active" on load

---

## FR-011 System-Defined Dynamic Recipient List

- ID: FR-011
  - Title: All club contacts system list visible and de-duplicated
  - Expected: Read-only list aggregates unique contacts from all sources

---

## FR-012 Admin Confirmation Email

- ID: FR-012.S01
  - Title: Send confirmation email upon successful import
  - Preconditions: 100% valid import
  - Steps: Complete import
  - Expected: Confirmation email to uploader (Transactional/Operational; non-PII summary)

- ID: FR-012.S02
  - Title: Send email on failed or aborted import
  - Expected: Email to uploader with non-PII diagnostic information

---

## Notes & Test Hints
- Use canonicalisation for email comparisons (lowercase, trimmed, normalize BOM)
- Do not override existing MyAccount preferences; only populate unset fields
- Verification tokens should be invalidated when a fresh token is issued
- Enforce row and size caps strictly (no partial commits)

## File
Specification generated from [features/bulk_contacts_upload.feature](features/bulk_contacts_upload.feature)
