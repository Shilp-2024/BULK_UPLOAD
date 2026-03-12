# Requirements Traceability Matrix (RTM)
## Bulk Contacts Upload Feature

**Document Version:** 1.0  
**Date:** 12 March 2026  
**Status:** Ready for Test Execution

---

## Executive Summary

This Requirements Traceability Matrix (RTM) establishes bidirectional traceability between:
- **BRD Requirements** (FR-001 through FR-012, NFR-001 through NFR-005)
- **Test Cases** (50 comprehensive test cases across 19 modules)
- **Acceptance Criteria** (All scenarios defined in BRD)

### Coverage Summary
- **Total BRD Requirements:** 12 FR + 5 NFR = 17
- **Total Test Cases:** 50
- **Coverage Status:** ✅ 100% (All requirements traced to tests)

---

## Part 1: Requirements to Test Case Mapping

### FR-001: Access Control & Entry to Bulk Import

**Requirement Statement:**  
The system must restrict access to the Bulk Import area to authorised users only and expose it via a single "Bulk Import" entry point. SU + BO feature flags.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Authorised user sees Bulk Import entry | TC-AC-01 | Authorized user can access Bulk Import | High | ✅ |
| Club-level feature flag disabled hides/disables | TC-AC-02 | Feature flag disabled hides Bulk Import | High | ✅ |
| User without permission cannot access | TC-AC-03 | Unauthorized user blocked from deep link | High | ✅ |

**Coverage:** ✅ 100%

---

### FR-002: Bulk Import Launcher: Choose Import Type

**Requirement Statement:**  
The system must present a launcher screen with three options: Contacts, Membership registrations, Lotto playslips, and route accordingly.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Launcher shows three import types | TC-LA-01 | Launcher presents three import types | Medium | ✅ |
| Contacts tile routes to Contacts upload | TC-LA-02 | Contacts tile opens Contacts flow | Medium | ✅ |
| Memberships tile routes to Membership bulk import | TC-LA-03 | Membership tile opens Membership flow | Medium | ✅ |
| Playslips tile routes to Lotto bulk import | TC-LA-04 | Playslips tile opens Lotto flow | Medium | ✅ |

**Coverage:** ✅ 100%

---

### FR-003: CSV Upload & Validation

**Requirement Statement:**  
The system must accept a fixed‑schema CSV (A=First Name, B=Last Name, C=Email; header required), validate all rows, display invalid rows inline with reasons, and block progression until the dataset is 100% valid.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Valid CSV proceeds to Review | TC-CSV-01 | Valid CSV advances to Review | High | ✅ |
| Missing header row blocks parse | TC-CSV-02 | Missing header blocks parse | High | ✅ |
| Required fields blank → row invalid | TC-CSV-03 | Blank required fields flagged | High | ✅ |
| Email format invalid → row invalid | TC-CSV-04 | Invalid email formats flagged | High | ✅ |
| In-file duplicate emails collapsed and flagged | TC-CSV-05 | In-file duplicates collapsed and flagged | High | ✅ |
| Existing account + name mismatch handling | TC-EX-01 | Name mismatch shows warning | High | ✅ |
| File size/row caps exceeded blocks parse | TC-CSV-07 | File caps exceeded blocks parse | High | ✅ |
| No downloadable error file; re-upload required | (Implicit in all CSV tests) | Re-upload via UI message | - | ✅ |
| Encoding/whitespace normalization | TC-CSV-06 | Whitespace and canonicalisation | Medium | ✅ |

**Coverage:** ✅ 100%

---

### FR-004: Silent Account Creation & Verification for New Contacts

**Requirement Statement:**  
The system must silently create accounts for emails not found in the system and send a verification email to those new contacts only; existing contacts are not notified after upload.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| New email → account created, verification sent | TC-SA-01 | New email creates account and sends verification | High | ✅ |
| Existing email not re-notified | TC-SA-02 | Existing accounts not notified | High | ✅ |
| Account created email toggle ON (default) | TC-SA-03 | Account-created email toggle ON sends both | Medium | ✅ |
| Account created email toggle OFF | TC-SA-04 | Toggle OFF suppresses account-created email | Medium | ✅ |
| Hard bounce → UNDELIVERABLE | TC-SA-05 | Verification hard bounce marks UNDELIVERABLE | High | ✅ |

**Coverage:** ✅ 100%

---

### FR-005: Lists (Static & Lotto/50/50 Lists)

**Requirement Statement:**  
The system must allow creating a Static List and/or adding uploaded contacts to existing Lists, including Active/Expired lotto players when Lotto consent is attested at upload.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Create Static List during import | TC-LS-01 | Create new Static List during import | High | ✅ |
| Add to existing Static List | TC-LS-02 | Add to existing Static List no duplicates | High | ✅ |
| Add to Active/Expired lotto lists with consent | TC-LS-03 | Add to Active lotto players with consent | High | ✅ |
| Cannot add to lotto lists without consent | TC-LS-04 | Block adding to lotto without consent | High | ✅ |

**Coverage:** ✅ 100%

---

### FR-006: Consent Attestation (Batch) & MyAccount Mapping

**Requirement Statement:**  
Admin can provide consent for General club news and club marketing and/or Lotto / Draw notifications for uploaded club contacts. Store audit (uploader id, timestamp, consent types). Apply flags after verification. Users can change preferences in MyAccount.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Consent audit recorded with uploader ID, timestamp | TC-CA-01 | Batch-level consent audit persisted | High | ✅ |
| Consent applied after verification if unset | TC-CA-02 | Attested consent populates after verify when unset | High | ✅ |
| Do not override existing preferences | TC-CA-03 | Do not override existing preferences | High | ✅ |

**Coverage:** ✅ 100%

---

### FR-007: MyAccount Preferences & Migration Defaults

**Requirement Statement:**  
The system must expose per-club preferences (Club comms master, Marketing, Lotto notifications) and define secure defaults for existing account holders.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Migration defaults Email=Yes → Marketing=Yes | TC-MYA-01 | Migration defaults for existing Email=Yes | Medium | ✅ |
| Migration sets Lotto=Yes for historical entrants | TC-MYA-02 | Migration sets Lotto=Yes for lotto entrants | Medium | ✅ |
| User updates per-club preferences | TC-MYA-03 | User updates per-club preferences | Medium | ✅ |

**Coverage:** ✅ 100%

---

### FR-008: Send‑time Eligibility

**Requirement Statement:**  
The system must evaluate recipients against verification, consent, purpose, deliverability, and lotto rules with reconciling totals (Matched = Eligible + Suppressed).

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Marketing requires Verified + consent=Yes | TC-SEND-01 | Marketing send includes only Verified + Marketing=Yes | High | ✅ |
| Transactional bypasses marketing consent | TC-SEND-02 | Transactional override requires confirmation | High | ✅ |
| Unverified global suppression | TC-SEND-03 | Unverified global suppression | High | ✅ |

**Coverage:** ✅ 100%

---

### FR-009: Compose Emails (Default Marketing, Eligibility Counts, Transactional Override)

**Requirement Statement:**  
The system must default once-off and recurring club emails to General club news and marketing, compute and display recipient eligibility (matched total vs eligible total) based on consent/verification rules, and allow a Transactional override that sends to all matched recipients only after explicit confirmation by the sender.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Default to Marketing classification | TC-COMP-01 | Default to Marketing classification and show counts | High | ✅ |
| Compute and display counts (Matched vs Eligible) | TC-COMP-01 | (Same test covers count display) | High | ✅ |
| Deduplicate recipients across multiple lists | TC-COMP-02 | Deduplicate recipients across multiple lists | High | ✅ |
| Transactional override requires confirmation checkbox | TC-COMP-03 | Transactional override requires confirmation | High | ✅ |
| Recurring emails re-evaluate at send time | TC-COMP-04 | Recurring emails re-evaluate at send time | Medium | ✅ |

**Coverage:** ✅ 100%

---

### FR-010: Split Lotto Players into Active/Expired

**Requirement Statement:**  
The system must replace the existing single System List: "Lotto players" with two distinct System Lists: "Lotto players - active" and "Lotto players - expired", and ensure these lists are selectable and behave correctly when sending a message. The same for Draw (50/50) players.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Recipients dropdown shows active/expired and removes legacy | TC-LO-01 | Recipients dropdown shows active+expired | Medium | ✅ |
| Legacy recurring emails mapped to active | TC-LO-02 | Legacy recurring mapping to active | Medium | ✅ |

**Coverage:** ✅ 100%

---

### FR-011: System-Defined Dynamic Recipient List: "All club contacts"

**Requirement Statement:**  
The system must provide a read-only, system-defined dynamic recipient list called "All club contacts". This list automatically aggregates every unique contact associated with the club from any source and is continuously updated and de-duplicated during send.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| "All club contacts" list visible and selectable | TC-SYS-01 | All club contacts system list visible | Medium | ✅ |
| Aggregates all sources; deduplicated | TC-SYS-01 | (Same test covers aggregation and dedup) | Medium | ✅ |

**Coverage:** ✅ 100%

---

### FR-012: Admin Confirmation Email on Successful Bulk Upload

**Requirement Statement:**  
The system must send a confirmation email to the uploading admin after a successful Contacts bulk upload, summarising the import, consents, list actions, and next steps, without exposing contact PII in the email body.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Email sent on successful import | TC-ADM-01 | Admin receives confirmation with non-PII summary | High | ✅ |
| Email contains non-PII summary | TC-ADM-01 | (Same test covers PII protection) | High | ✅ |
| Email sent on failed/aborted import | TC-ADM-02 | Admin receives notification on failed import | Medium | ✅ |

**Coverage:** ✅ 100%

---

## Part 2: Non-Functional Requirements to Test Case Mapping

### NFR-001: Performance

**Requirement Statement:**  
Validate ≤1,000 rows within 10 seconds

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Validation completes within 10 seconds | TC-NFR-01 | Validate ≤1000 rows within 10s | High | ✅ |

**Coverage:** ✅ 100%

---

### NFR-002: Reliability

**Requirement Statement:**  
99.9% monthly availability for upload services.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Service availability and retry semantics | TC-NFR-02 | Upload service availability and retries | Medium | ✅ |

**Coverage:** ✅ 100%

---

### NFR-003: Security/Privacy

**Requirement Statement:**  
Consent attestation stored with uploader id, IP, timestamp

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Consent audit includes uploader id, IP, timestamp | TC-NFR-03 | Consent audit with uploader id, IP, timestamp | High | ✅ |

**Coverage:** ✅ 100%

---

### NFR-004: Auditability

**Requirement Statement:**  
Batch-level attestation and send eligibility decisions logged and queryable.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Batch attestation logged | TC-CA-01 | Batch-level consent audit persisted | High | ✅ |

**Coverage:** ✅ 100%

---

### NFR-005: Deliverability

**Requirement Statement:**  
Hard bounces set UNDELIVERABLE via ESP webhooks; exclude from sends until updated.

| Acceptance Criteria | Test Case ID | Test Summary | Priority | Status |
|-------------------|-------------|--------------|----------|--------|
| Hard bounces mark UNDELIVERABLE | TC-NFR-04 | Hard bounces set UNDELIVERABLE via webhook | High | ✅ |
| UNDELIVERABLE excluded from sends | TC-SA-05 | (Same test covers exclusion) | High | ✅ |

**Coverage:** ✅ 100%

---

## Part 3: Test Case to Requirement Mapping

This section lists all test cases and their corresponding requirements.

| Test Case ID | Test Summary | Module | Related FR/NFR | Priority |
|--------------|--------------|--------|-----------------|----------|
| TC-AC-01 | Authorized user can access Bulk Import | Access Control | FR-001 | High |
| TC-AC-02 | Feature flag disabled hides Bulk Import | Access Control | FR-001 | High |
| TC-AC-03 | Unauthorized user blocked from deep link | Access Control | FR-001 | High |
| TC-LA-01 | Launcher presents three import types | Launcher | FR-002 | Medium |
| TC-LA-02 | Contacts tile opens Contacts flow | Launcher | FR-002 | Medium |
| TC-LA-03 | Membership tile opens Membership flow | Launcher | FR-002 | Medium |
| TC-LA-04 | Playslips tile opens Lotto flow | Launcher | FR-002 | Medium |
| TC-CSV-01 | Valid CSV advances to Review | CSV Validation | FR-003 | High |
| TC-CSV-02 | Missing header blocks parse | CSV Validation | FR-003 | High |
| TC-CSV-03 | Blank required fields flagged | CSV Validation | FR-003 | High |
| TC-CSV-04 | Invalid email formats flagged | CSV Validation | FR-003 | High |
| TC-CSV-05 | In-file duplicates flagged | CSV Validation | FR-003 | High |
| TC-CSV-06 | Whitespace and canonicalisation | CSV Validation | FR-003 | Medium |
| TC-CSV-07 | File caps exceeded blocks parse | CSV Validation | FR-003 | High |
| TC-EX-01 | Name mismatch shows warning | Existing Account | FR-003 | High |
| TC-EX-02 | Hard-block name mismatch (config) | Existing Account | FR-003 | Medium |
| TC-SA-01 | New email creates account & verification | Account Creation | FR-004 | High |
| TC-SA-02 | Existing accounts not notified | Account Creation | FR-004 | High |
| TC-SA-03 | Account-created email toggle ON | Account Creation | FR-004 | Medium |
| TC-SA-04 | Toggle OFF suppresses account-created | Account Creation | FR-004 | Medium |
| TC-SA-05 | Verification bounce → UNDELIVERABLE | Account Creation | FR-004, NFR-005 | High |
| TC-LS-01 | Create new Static List | Lists | FR-005 | High |
| TC-LS-02 | Add to existing Static List | Lists | FR-005 | High |
| TC-LS-03 | Add to Active lotto with consent | Lotto | FR-005 | High |
| TC-LS-04 | Block lotto without consent | Lotto | FR-005 | High |
| TC-CA-01 | Batch consent audit persisted | Consent | FR-006, NFR-003, NFR-004 | High |
| TC-CA-02 | Consent applies after verify (unset) | Consent | FR-006 | High |
| TC-CA-03 | Don't override existing prefs | Consent | FR-006 | High |
| TC-MYA-01 | Migration Email=Yes → Marketing=Yes | MyAccount | FR-007 | Medium |
| TC-MYA-02 | Migration Lotto=Yes for entrants | MyAccount | FR-007 | Medium |
| TC-MYA-03 | User updates per-club prefs | MyAccount | FR-007 | Medium |
| TC-COMP-01 | Default Marketing; show counts | Compose | FR-009 | High |
| TC-COMP-02 | Deduplicate across lists | Compose | FR-009 | High |
| TC-COMP-03 | Transactional override confirmed | Compose | FR-009 | High |
| TC-COMP-04 | Recurring re-evaluate at send | Compose | FR-009 | Medium |
| TC-SEND-01 | Marketing = Verified + consent | Send Eligibility | FR-008 | High |
| TC-SEND-02 | Transactional override | Send Eligibility | FR-008 | High |
| TC-SEND-03 | Unverified suppression | Send Eligibility | FR-008 | High |
| TC-LO-01 | Active/Expired visible; legacy gone | Lotto | FR-010 | Medium |
| TC-LO-02 | Legacy recurring → active | Lotto | FR-010 | Medium |
| TC-SYS-01 | All club contacts visible & dedup | Recipients | FR-011 | Medium |
| TC-ADM-01 | Admin confirmation with non-PII | Notifications | FR-012 | High |
| TC-ADM-02 | Admin notified on failure | Notifications | FR-012 | Medium |
| TC-NFR-01 | Validate ≤1000 rows in 10s | Performance | NFR-001 | High |
| TC-NFR-02 | Upload service availability | Reliability | NFR-002 | Medium |
| TC-NFR-03 | Consent audit w/ IP & timestamp | Security | NFR-003 | High |
| TC-NFR-04 | Hard bounces → UNDELIVERABLE | Deliverability | NFR-005 | High |
| TC-EDGE-01 | Extra columns rejected/ignored | CSV Edge | FR-003 | High |
| TC-EDGE-02 | UTF-8 & special chars handled | CSV Edge | FR-003 | Medium |
| TC-EDGE-03 | Lists disabled during updates | Background job | FR-005 | Medium |

**Total Test Cases:** 50  
**Coverage:** ✅ 100% of all FR and NFR requirements

---

## Part 4: Coverage Analysis

### By Functional Requirement

| Requirement | Test Cases | Coverage |
|-------------|-----------|----------|
| FR-001 (Access Control) | 3 | ✅ 100% |
| FR-002 (Launcher) | 4 | ✅ 100% |
| FR-003 (CSV Validation) | 10 | ✅ 100% |
| FR-004 (Account Creation) | 5 | ✅ 100% |
| FR-005 (Lists) | 4 | ✅ 100% |
| FR-006 (Consent) | 3 | ✅ 100% |
| FR-007 (MyAccount) | 3 | ✅ 100% |
| FR-008 (Send Eligibility) | 3 | ✅ 100% |
| FR-009 (Compose) | 4 | ✅ 100% |
| FR-010 (Lotto Split) | 2 | ✅ 100% |
| FR-011 (All Contacts) | 1 | ✅ 100% |
| FR-012 (Admin Email) | 2 | ✅ 100% |

---

### By Non-Functional Requirement

| Requirement | Test Cases | Coverage |
|-------------|-----------|----------|
| NFR-001 (Performance) | 1 | ✅ 100% |
| NFR-002 (Reliability) | 1 | ✅ 100% |
| NFR-003 (Security/Privacy) | 1 | ✅ 100% |
| NFR-004 (Auditability) | 1 | ✅ 100% |
| NFR-005 (Deliverability) | 2 | ✅ 100% |

---

### By Priority

| Priority | Count | Percentage |
|----------|-------|-----------|
| High | 31 | 62% |
| Medium | 19 | 38% |

---

### By Module

| Module | Count | Priority Mix |
|--------|-------|--------------|
| CSV Validation | 9 | 6H + 3M |
| Account Creation | 5 | 3H + 2M |
| Compose | 4 | 3H + 1M |
| Launcher | 4 | 0H + 4M |
| Lotto | 6 | 2H + 4M |
| MyAccount | 3 | 0H + 3M |
| Consent | 3 | 3H + 0M |
| Send Eligibility | 3 | 3H + 0M |
| Access Control | 3 | 3H + 0M |
| Notifications | 2 | 1H + 1M |
| Existing Account | 2 | 1H + 1M |
| Lists | 2 | 2H + 0M |
| Recipients | 1 | 0H + 1M |
| Performance | 1 | 1H + 0M |
| Reliability | 1 | 0H + 1M |
| Security | 1 | 1H + 0M |
| Deliverability | 1 | 1H + 0M |
| CSV Edge | 2 | 1H + 1M |
| Background Job | 1 | 0H + 1M |

---

## Part 5: Traceability Gaps & Notes

### Requirements with Adequate Coverage
✅ All 12 Functional Requirements (FR-001 through FR-012)  
✅ All 5 Non-Functional Requirements (NFR-001 through NFR-005)  
✅ All Acceptance Criteria from BRD

### Known Issues & Open Questions (from BRD)
- **File size/row caps:** Placeholder values (10MB, 5000 rows) used in tests; confirm actual values with Engineering
- **Token expiration policy:** Specific token TTL not defined; tests assume standard email verification flow
- **Hard-block vs soft-merge:** Both approaches documented; tests assume soft-merge default
- **50/50 draw listing:** Mirrors lotto split logic; specific requirements to be confirmed

### Recommendations for Test Execution
1. **Execute P0/High tests first** (31 cases) to validate critical paths
2. **Perform CSV validation tests early** (9 cases) to catch data quality issues
3. **Run send eligibility tests** (3 cases) to verify compliance logic
4. **Execute edge cases** (2+ cases) for robustness validation

---

## Part 6: Test Execution Metrics Template

Use this section to track test execution:

| Test Case ID | Executed | Pass | Fail | Blocked | Notes |
|--------------|----------|------|------|---------|-------|
| TC-AC-01 | [ ] | [ ] | [ ] | [ ] | |
| TC-AC-02 | [ ] | [ ] | [ ] | [ ] | |
| TC-AC-03 | [ ] | [ ] | [ ] | [ ] | |
| (Continue for all 50 cases...) | | | | | |

---

## Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| QA Lead | __________ | __________ | ____ |
| Product Manager | __________ | __________ | ____ |
| Engineering Lead | __________ | __________ | ____ |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12-Mar-2026 | QA Team | Initial RTM for test suite |
| | | | |

---

## Appendix A: Requirement-Test Case Cross-Reference Quick Index

### Access Control Path
- FR-001 → TC-AC-01, TC-AC-02, TC-AC-03

### CSV & Data Quality Path
- FR-003 → TC-CSV-01 through TC-CSV-07, TC-EX-01, TC-EX-02, TC-EDGE-01, TC-EDGE-02

### Account & Verification Path
- FR-004 → TC-SA-01 through TC-SA-05, NFR-005

### List Management Path
- FR-005 → TC-LS-01 through TC-LS-04, TC-EDGE-03

### Consent & Preferences Path
- FR-006, FR-007 → TC-CA-01 through TC-CA-03, TC-MYA-01 through TC-MYA-03, NFR-003, NFR-004

### Email & Send Path
- FR-008, FR-009 → TC-SEND-01 through TC-SEND-03, TC-COMP-01 through TC-COMP-04

### System Lists & Admin Path
- FR-010, FR-011, FR-012 → TC-LO-01, TC-LO-02, TC-SYS-01, TC-ADM-01, TC-ADM-02

### Performance & Non-Functional Path
- NFR-001, NFR-002 → TC-NFR-01, TC-NFR-02
- NFR-005 → TC-NFR-04, TC-SA-05

---

**End of Traceability Matrix**
