# Test Execution Guide & Risk Assessment Matrix

## Quick Reference: Test Case IDs by Feature

### Access Control (AC)
- TC-AC-001: Authorized access
- TC-AC-002: Feature flag disabled
- TC-AC-003: Permission denied (deep link)
- TC-AC-004: Non-admin access denied
- TC-AC-005: Multiple roles validation
- TC-AC-006: Feature flag state affects UI

### Launcher (LA)
- TC-LA-001: Three import types display
- TC-LA-002: Contacts routing
- TC-LA-003: Memberships routing
- TC-LA-004: Playslips routing

### CSV Validation & Parsing (CSV)
- TC-CSV-001: Valid CSV → Review
- TC-CSV-002: Missing header → Blocked
- TC-CSV-003: Missing First Name → Invalid
- TC-CSV-004: Missing Last Name → Invalid
- TC-CSV-005: Missing Email → Invalid
- TC-CSV-006: Invalid email (@@) → Invalid
- TC-CSV-007: Invalid email (no @) → Invalid
- TC-CSV-008: Invalid email (no TLD) → Invalid
- TC-CSV-009: In-file duplicates → Flagged
- TC-CSV-010: Multiple in-file duplicates → Handled
- TC-CSV-011: Existing + name match → Valid
- TC-CSV-012: Existing + first name mismatch → Warning
- TC-CSV-013: Existing + last name mismatch → Warning
- TC-CSV-014: File size exceeded → Blocked
- TC-CSV-015: Row count exceeded → Blocked
- TC-CSV-016: Max valid rows → Accepted
- TC-CSV-017: Whitespace trimmed
- TC-CSV-018: Email canonicalization
- TC-CSV-019: UTF-8 special characters
- TC-CSV-020: BOM handling
- TC-CSV-021: Mixed valid/invalid rows
- TC-CSV-022: No error file download
- TC-CSV-023: Validation performance (<10s)

### Silent Account Creation (SA)
- TC-SA-001: New email → Account + Verification
- TC-SA-002: Existing email → No re-notification
- TC-SA-003: Multiple new accounts
- TC-SA-004: Mixed batch (new + existing)
- TC-SA-005: Verification triggers eligibility
- TC-SA-006: Hard bounce → UNDELIVERABLE
- TC-SA-007: Account created email ON
- TC-SA-008: Account created email OFF
- TC-SA-009: Login resend verification
- TC-SA-010: Unverified suppression platform-wide

### Lists & Lotto (LS)
- TC-LS-001: Create Static List
- TC-LS-002: Add to existing Static List
- TC-LS-003: Multiple list selection
- TC-LS-004: Lotto lists with consent
- TC-LS-005: Lotto lists without consent → Blocked
- TC-LS-006: Empty list creation → Prevented
- TC-LS-007: List update background job

### Consent & MyAccount (CA)
- TC-CA-001: Consent attestation + audit
- TC-CA-002: Consent applied after verification
- TC-CA-003: No attestation → Unset
- TC-CA-004: Consent populated when unset
- TC-CA-005: Existing prefs not overridden
- TC-CA-006: Mixed batch (set + unset)
- TC-CA-007: User changes remain authoritative
- TC-CA-008: SMS label (not Mobile)

### Send-time Eligibility (SEND)
- TC-SEND-001: Marketing = Verified + Consent
- TC-SEND-002: Transactional bypasses consent
- TC-SEND-003: Zero eligible → Blocked
- TC-SEND-004: Override requires checkbox
- TC-SEND-005: Deduplicate across lists
- TC-SEND-006: Lotto results eligibility
- TC-SEND-007: UNDELIVERABLE suppression
- TC-SEND-008: Recurring re-evaluates
- TC-SEND-009: Count reconciliation

### Compose Emails (COMP)
- TC-COMP-001: Default = Marketing
- TC-COMP-002: Matched vs Eligible counts
- TC-COMP-003: Background job disables lists
- TC-COMP-004: Marketing = Eligible only
- TC-COMP-005: Zero eligible = Blocked
- TC-COMP-006: Override checkbox
- TC-COMP-007: Transactional sends all (except UNDELIVERABLE)
- TC-COMP-008: Audit logging
- TC-COMP-009: Recurring re-evaluates

### Lotto Players Split (LOTTO)
- TC-LOTTO-001: Active/Expired lists visible
- TC-LOTTO-002: Legacy email mapping
- TC-LOTTO-003: Active = Active only
- TC-LOTTO-004: Expired = Expired only
- TC-LOTTO-005: Both = Deduplicated union
- TC-LOTTO-006: Recurring re-evaluates
- TC-LOTTO-007: Mixed list deduplication
- TC-LOTTO-008: 50/50 draw split mirrors lotto

### All Club Contacts (ALL)
- TC-ALL-001: Dynamic list visible
- TC-ALL-002: Aggregates all sources
- TC-ALL-003: Read-only enforcement

### Admin Confirmation Email (ADM)
- TC-ADM-001: Email sent on success
- TC-ADM-002: No PII in email
- TC-ADM-003: List actions in summary
- TC-ADM-004: Email sent on failure

### Security (SEC)
- TC-SEC-001: Audit includes IP
- TC-SEC-002: No PII in audit
- TC-SEC-003: Token expiration
- TC-SEC-004: SQL injection prevention
- TC-SEC-005: File type validation

### Performance (NFR)
- TC-NFR-001: Validation <10s for 1000 rows
- TC-NFR-002: Batch account creation SLA
- TC-NFR-003: Email send SLA
- TC-NFR-004: UI responsiveness

### Edge Cases (EDGE)
- TC-EDGE-001: Empty file (header only)
- TC-EDGE-002: Max length names
- TC-EDGE-003: Special characters
- TC-EDGE-004: Email plus addressing
- TC-EDGE-005: Unverified re-upload
- TC-EDGE-006: Concurrent imports
- TC-EDGE-007: Single character names
- TC-EDGE-008: Numeric chars in names
- TC-EDGE-009: Whitespace-only fields
- TC-EDGE-010: Duplicate + existing combo

### Usability (USAB)
- TC-USAB-001: Error message clarity
- TC-USAB-002: Progress indicator
- TC-USAB-003: Review summary clarity
- TC-USAB-004: Disabled state explanation
- TC-USAB-005: Button label consistency

### Regression (REG)
- TC-REG-001: Membership upload unaffected
- TC-REG-002: Send functionality unaffected
- TC-REG-003: MyAccount unchanged
- TC-REG-004: Verification workflow unchanged
- TC-REG-005: Deliverability webhook unchanged

---

## Risk Assessment Matrix

### Critical Risks (Test Immediately)

| Risk | Impact | Likelihood | Exposure | Test Cases | Mitigation |
|------|--------|-----------|----------|-----------|-----------|
| **Duplicate Account Creation** | Critical | Medium | High | TC-CSV-009, TC-CSV-010, TC-SA-001, TC-SA-002, TC-EDGE-005 | Duplicate detection logic in CSV validation; verify existing account check before creation |
| **Unverified Contact Eligibility** | Critical | Medium | High | TC-SA-010, TC-SEND-001, TC-SEND-007 | Platform-wide unverified suppression; audit eligibility rules |
| **Consent Override Bug** | Critical | Low | Medium | TC-CA-005, TC-CA-006, TC-CA-007 | Strict test of "populate only if unset" logic; verify existing prefs never overwritten |
| **Defective CSV Parsing** | High | Medium | High | TC-CSV-001 through TC-CSV-023 | Comprehensive validation; test all error conditions; verify blocking on invalids |
| **Broken List Deduplication** | High | Low | Medium | TC-SEND-005, TC-LOTTO-005, TC-LOTTO-007 | Verify deduplication logic across multiple lists; test recipient counts |

### High Risks (Test Early in Cycle)

| Risk | Impact | Likelihood | Exposure | Test Cases | Mitigation |
|------|--------|-----------|----------|-----------|-----------|
| **Incorrect Send Eligibility** | High | Medium | High | TC-SEND-001 through TC-SEND-009, TC-COMP-001 through TC-COMP-009 | Test all combinations of verification + consent; audit eligibility counts |
| **Missing Verification Emails** | High | Low | Medium | TC-SA-001, TC-SA-003, TC-SA-004 | Monitor email delivery; verify count of verification emails sent |
| **Lotto List Mapping Failure** | High | Low | Medium | TC-LOTTO-001 through TC-LOTTO-008 | Test legacy list updates; verify active/expired split logic |
| **Access Control Bypass** | High | Low | High | TC-AC-001 through TC-AC-006 | Test permission checks; verify feature flag enforcement |
| **Performance SLA Miss** | High | Medium | Medium | TC-NFR-001 through TC-NFR-004 | Test with max row counts; profile validation and send operations |

### Medium Risks (Test Throughout Cycle)

| Risk | Impact | Likelihood | Exposure | Test Cases | Mitigation |
|------|--------|-----------|----------|-----------|-----------|
| **Consent Audit Log Missing** | Medium | Low | Low | TC-CA-001 | Verify audit records written; check uploader ID, timestamp, IP |
| **Admin Email PII Exposure** | Medium | Low | High | TC-ADM-002 | Audit email template; verify no contact PII in body |
| **Race Condition on List Updates** | Medium | Low | Medium | TC-LS-007, TC-COMP-003, TC-EDGE-006 | Test background job locking; verify UI state during updates |
| **Encoding Issues** | Medium | Low | Medium | TC-CSV-019, TC-CSV-020 | Test UTF-8, BOM, special characters; verify stored correctly |
| **Whitespace Normalization Fail** | Medium | Low | Low | TC-CSV-017 | Test leading/trailing spaces; verify trimming |

### Low Risks (Test as Time Allows)

| Risk | Impact | Likelihood | Exposure | Test Cases | Mitigation |
|------|--------|-----------|----------|-----------|-----------|
| **UI Button Label Inconsistency** | Low | Low | Low | TC-USAB-005 | Visual regression testing; check labels across steps |
| **Regression in Membership Upload** | Low | Low | Low | TC-REG-001 | Smoke test membership flow; verify no unintended changes |
| **Missing Progress Indicator** | Low | Low | Low | TC-USAB-002 | Visual inspection; verify progress bar during large uploads |
| **Disabled Option Not Explained** | Low | Low | Low | TC-USAB-004 | Tooltip/message inspection; verify explanatory text |

---

## Test Execution Checklist

### Pre-Execution
- [ ] Test environment set up and verified
- [ ] Test data prepared (CSV files, contact lists, etc.)
- [ ] Test accounts created (Club Admin, Comms Admin, PRO, Account Holder)
- [ ] Feature flags configured for test scenarios
- [ ] Email monitoring/webhook capture ready
- [ ] Audit log access verified
- [ ] Database backup taken before testing

### During Execution
- [ ] Track test status (Passed/Failed/Blocked/Skipped)
- [ ] Document actual results vs expected
- [ ] Capture screenshots/videos of failures
- [ ] Monitor system performance metrics
- [ ] Monitor email delivery
- [ ] Check audit log entries
- [ ] Monitor error logs for exceptions

### Post-Execution
- [ ] Test run report generated
- [ ] Failed tests analyzed and classified
- [ ] Defects logged with reproducible steps
- [ ] Regression test pack results reviewed
- [ ] Performance metrics analyzed
- [ ] Coverage gaps identified
- [ ] Stakeholder update prepared

---

## Defect Severity Levels

| Severity | Criteria | Example | Example Test Cases |
|----------|----------|---------|-------------------|
| **Critical (P0)** | System crash, data loss, security breach, hard business rule violation | Duplicate account created; unverified contact receives marketing email | TC-SA-001, TC-SEND-001, TC-AC-001 |
| **High (P1)** | Major feature broken, incorrect behavior per spec, impacts multiple users | CSV validation doesn't block invalid emails | TC-CSV-006, TC-SEND-005 |
| **Medium (P2)** | Minor feature broken, workaround exists, limited impact | Email label shows "Mobile" instead of "SMS" | TC-CA-008 |
| **Low (P3)** | UI inconsistency, typo, improvement opportunity | Button labels inconsistent across steps | TC-USAB-005 |

---

## Test Data Management

### CSV Test Files Location
```
/tests/
├── comprehensive_test_suite.csv  (120+ test cases)
├── TEST_SUITE_SUMMARY.md         (This reference)
├── data/
│   ├── valid_contacts.csv         (3-1000 rows, no errors)
│   ├── invalid_emails.csv         (5 rows, bad emails)
│   ├── duplicate_contacts.csv     (5 rows, in-file duplicates)
│   ├── missing_required_fields.csv (5 rows, missing fields)
│   ├── edge_cases.csv             (10 rows, special chars)
│   ├── large_file_500_rows.csv    (500-6000 rows for perf)
│   ├── max_length_names.csv       (3 rows, boundary tests)
│   └── mixed_valid_invalid.csv    (10 rows, mixed scenarios)
```

### Contact Test Accounts

| Account | Role | Purpose | Email |
|---------|------|---------|-------|
| TestAdmin001 | Club Admin | Access control, upload tests | testadmin001@testclub.ie |
| TestComms001 | Comms Admin | Upload, compose, send tests | testcomms001@testclub.ie |
| TestPRO001 | Club PRO | Send eligibility tests | testpro001@testclub.ie |
| TestAH001 | Account Holder | Verification, MyAccount tests | testah001@testclub.ie |

### Test Club Setup

| Club | Feature Flag | Lists | Initial Contacts | Purpose |
|------|-------|-------|------------------|---------|
| TestClub001 | Enabled | None (create during tests) | 100 (existing) | Primary test club |
| TestClub002 | Disabled | N/A | 50 | Feature flag test club |
| TestClub003 | Enabled | Supporters, Members, Lotto | 200 | Existing list test club |

---

## Key Metrics to Track

### Test Execution Metrics
- **Total Test Cases:** 120
- **Total Passed:** ___ (% Pass Rate)
- **Total Failed:** ___ (% Fail Rate)
- **Total Blocked:** ___ (% Blocked Rate)
- **Total Skipped:** ___ (% Skip Rate)
- **Average Test Duration:** ___ minutes
- **Total Execution Time:** ___ hours

### Quality Metrics
- **Defects Found:** ___
  - Critical (P0): ___
  - High (P1): ___
  - Medium (P2): ___
  - Low (P3): ___
- **Defects Fixed:** ___
- **Open Defects:** ___
- **Defect Closure Rate:** ___% 
- **Code Coverage:** ___% (if available)

### Performance Metrics
- **Average Validation Time (1000 rows):** ___ seconds (Target: ≤10s)
- **Average Account Creation Time (100 contacts):** ___ seconds
- **Average Email Send Time (500 recipients):** ___ seconds
- **UI Response Time (List Dropdown):** ___ ms

### Compliance Metrics
- **Security Issues Found:** ___
- **Audit Trail Coverage:** ___% (check audit log entries)
- **PII Protection:** Pass/Fail
- **Feature Flag Compliance:** Pass/Fail

---

## Known Limitations & Open Questions

### From BRD

1. **File Size/Row Caps** - To be confirmed by Engineering
   - Placeholder: 10MB and 5000 rows
   - Action: Adjust test boundaries upon confirmation

2. **Verification Token Policy** - To be finalized
   - Expiration period unknown
   - Resend rules unclear
   - Action: Update TC-SEC-003 and TC-SA-009 upon finalization

3. **Active/Expired Lotto Logic** - 50/50 draw handling
   - How to handle scenarios where draw runs during background job
   - Action: Define edge case handling; update TC-LOTTO-006

4. **Additional CSV Fields**
   - Phone number, address field support unknown
   - Action: Determine scope; add tests if needed

5. **Soft-merge vs Hard-block** - Name mismatch handling
   - Feature unclear which path implemented
   - Action: Adjust TC-CSV-012 / TC-CSV-013 per implementation

---

## Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| QA Lead | ___________ | ________________ | _____ |
| Product Manager | ___________ | ________________ | _____ |
| Engineering Lead | ___________ | ________________ | _____ |

---

## Document Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12-Mar-2026 | QA Team | Initial comprehensive test suite |
| 1.1 | ___________ | ___________ | ________________ |
