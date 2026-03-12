# Bulk Contacts Upload - AI Agent Instructions

## Project Overview
BRD analysis and test specification workspace for a **Bulk Contacts Upload feature** in Clubforce (a membership/club management system). The feature enables club admins to bulk-import offline contacts via CSV, silently create accounts, send verifications, attach to lists, and enforce consent/verification rules at send-time.

**Key Stakeholders:** Club Admins, Comms Admins, Club PROs, Account Holders

## Architecture & Data Flow

### Three-Step Upload Process
1. **CSV Upload & Validation** - Fixed schema (First Name, Last Name, Email with header); inline error display; blocks proceed on invalidity
2. **Review & Options** - Consent attestation (Marketing, Lotto/Draw); list selection (create new or add to existing Static/Lotto lists)
3. **Confirmation & Silent Execution** - Accounts created for new emails; verification sent to new only; audit logged with uploader ID/timestamp

### Critical Integration Points
- **Duplicate Suppression:** Existing accounts (by email) prevent duplicate creation; names shown in warnings but not updated
- **Verification Flow:** New contacts receive verification email; unverified contacts suppressed from sends (hard-coded business rule)
- **Consent Mapping:** Batch-level attestation at upload time; applied to user MyAccount preferences only if unset; never overrides existing user-set preferences
- **Lotto/Draw System Lists:** Legacy "Lotto players" split into "Lotto players - active" and "Lotto players - expired"; contacts added only with consent attestation
- **Send-Time Eligibility:** Recipients evaluated against verification + purpose-based consent (Marketing vs Transactional); transactional override requires explicit confirmation

## Project-Specific Conventions

### Gherkin Feature File Organization
[features/bulk_contacts_upload.feature](../features/bulk_contacts_upload.feature) uses **FR-XXX.SYY** naming:
- **FR** = Functional Requirement (linked to BRD)
- **SYY** = Scenario within that requirement
- Use `Background` for common setup (user role, feature flag)
- **Example:** FR-003.S01 = CSV validation, first scenario

### Test Case Structure
[tests/generate_testcases_xlsx.py](../tests/generate_testcases_xlsx.py):
- Generates XLSX with columns: T_ID, Module, Priority, Test_Summary, Pre_request, Test_Steps, Expected_result, Result
- T_ID format: `TC-[Module-abbr]-[NN]` (e.g., TC-CSV-01, TC-SEND-02)
- Python script is the source of truth; run `python generate_testcases_xlsx.py` to generate the test matrix

### BRD Structure
[brd/bulk_contacts_brd.txt](../brd/bulk_contacts_brd.txt):
- Contains 11 Functional Requirements (FR-001 through FR-011)
- Sections: Business Goals, In Scope, Out of Scope, Functional Requirements, Non-Functional Requirements
- "Open Questions" section indicates unresolved decisions (e.g., hard-block vs soft-merge for name mismatches)

## Key Developer Workflows

### Validate CSV Parsing
- **Must support:** UTF-8, BOM, leading/trailing whitespace (trim), email canonicalisation for deduplication
- **Must reject:** Missing header, blank required fields, invalid email format, in-file duplicates (keep first)
- **Row caps:** System has row/size limits; validate <=1000 rows within 10 seconds (NFR-01)

### Consent & Preference Mapping
- Batch consent stored in audit log (uploader ID, timestamp, IP when available)
- On verification, apply attestation to MyAccount prefs **only if unset**
- Per-club preferences: Club comms master, Marketing, Lotto/Draw notifications

### Feature Flag Gating
- **Feature flags:** "Bulk import contacts" at club level gates visibility and access
- Unauthorized users: deep link `/bulk-import` returns access denied; no fallback

### Transactional vs Marketing Sends
- **Marketing:** Requires Verified=true AND purpose-specific consent (e.g., Marketing=Yes)
- **Transactional:** Override sends to all matched (non-UNDELIVERABLE) after explicit user confirmation checkbox
- Compose UI shows eligibility counts: Matched = Eligible + Suppressed (with suppression reasons)

## Critical Patterns & Edge Cases

### Existing Account Handling
- **Soft-merge (default):** Name mismatch shows warning; on upload, existing account name is authoritative (not updated)
- **Hard-block (configured):** Row marked Invalid if name differs; continue blocked
- No duplicate accounts created; verification not re-sent to existing accounts

### Undeliverable Suppression
- ESP hard bounces (via webhook) mark contact UNDELIVERABLE
- Contacts with UNDELIVERABLE status excluded from all non-transactional sends
- Transactional override includes UNDELIVERABLE (edge case; verify intent)

### List Update Race Conditions
- Lists being updated (background job) temporarily disabled for selection
- Show explanatory message to user during background processing

## Testing Patterns

### Test Modules (from TC naming)
- **AC:** Access Control (permissions, feature flags, deep links)
- **LA:** Launcher (three import types route correctly)
- **CSV:** CSV parsing and validation
- **EX:** Existing account handling
- **SA:** Silent account creation and verification
- **LS:** Lists and Lotto system list handling
- **CA:** Consent and MyAccount mapping
- **SEND:** Send-time eligibility and suppression
- **LO:** Lotto/Draw system list split and migration
- **ADM:** Admin notification emails
- **NFR:** Non-functional (performance, reliability, security)
- **EDGE:** Edge cases (encodings, special characters, concurrent updates)

### High-Priority Test Scenarios
- TC-AC-01, TC-CSV-01, TC-SA-01, TC-LS-01, TC-CA-01, TC-SEND-01, TC-ADM-01 (core flows)

## File Organization

```
BUlk Upload/
├── brd/
│   └── bulk_contacts_brd.txt          # Source of truth (BRD v1.1)
├── features/
│   └── bulk_contacts_upload.feature   # Gherkin scenarios (FR-mapped)
├── tests/
│   └── generate_testcases_xlsx.py     # Test case generator
├── docs/                               # (empty; for future documentation)
├── artifacts/                          # (empty; for reports/outputs)
└── README.md                           # Workspace setup instructions
```

## Common AI Agent Tasks

- **Adding scenarios:** Reference FR-XXX in BRD; use Background for setup; name as FR-XXX.S[NN]
- **Extending tests:** Update testcases array in Python script; run to regenerate XLSX
- **Resolving ambiguities:** Refer to BRD "Open Questions" section and prototype link (ChatGPT Canvas)
- **Feature flag logic:** Always check club-level flag before exposing UI; unauthorized users see greyed-out/disabled state
