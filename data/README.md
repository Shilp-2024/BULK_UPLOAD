# Bulk Contacts Upload - Test Data Reference

**Version:** 1.0  
**Date:** 11 March 2026  
**Location:** `/test_data/`

---

## Overview

This directory contains CSV test data files for validating the Bulk Contacts Upload feature. Each file is designed to test specific scenarios and edge cases outlined in the QA specification and automated test cases.

## Test Data Files

### 1. `valid_contacts.csv`
**Purpose:** Happy path testing - all data valid and properly formatted  
**Row Count:** 20 contacts  
**Use Cases:**
- TC-CSV-001: Valid CSV advances to Review
- TC-HP-001 to TC-HP-004: Happy path workflows
- Basic functionality testing
- Performance baseline

**Contents:**
- 20 valid contact records
- All required fields populated
- Proper email format (user@domain.ie)
- No duplicates
- No special characters or whitespace issues

**Expected Result:** 100% pass rate, 0 invalid rows

---

### 2. `duplicate_contacts.csv`
**Purpose:** Test in-file deduplication logic  
**Row Count:** 20 rows (15 unique)  
**Use Cases:**
- TC-DUP-001: In-file duplicate emails
- TC-DUP-002: Multiple in-file duplicates
- TC-DUP-004: Case-insensitive deduplication
- Validate row count accuracy

**Contents:**
- Row 2: john.duplicate@club.ie (canonical)
- Row 4: john.duplicate@club.ie (ignored)
- Row 6: alice@club.ie (canonical)
- Row 11: alice@club.ie (ignored)
- Row 15: DUPLICATE.EMAIL@CLUB.IE (canonical)
- Row 19: duplicate.email@club.ie (ignored - case-insensitive)

**Expected Result:**
- 5 unique contacts processed
- 5 duplicates flagged as "Duplicate in file (ignored)"
- Canonical records (first occurrence) kept
- Can proceed if no other invalids

---

### 3. `missing_required_fields.csv`
**Purpose:** Validate required field checking  
**Row Count:** 20 rows (7 completely invalid)  
**Use Cases:**
- TC-VAL-001: Required field blank (First Name)
- TC-VAL-002: Required field blank (Last Name)
- TC-VAL-003: Required field blank (Email)
- TC-VAL-004: Multiple blank fields
- TC-VAL-005: All fields blank

**Contents:**
- Row 2: blank First Name
- Row 4: blank Last Name
- Row 5: blank Email
- Row 8: blank First Name AND Email
- Row 10: all three fields blank
- Row 16: blank Last Name
- Row 18: blank Email
- Row 20: all blank

**Expected Result:**
- 7 rows marked "Invalid"
- Error messages specific to missing field(s)
- Continue button disabled until resolved
- Inline display of each invalid row with reasons

---

### 4. `invalid_emails.csv`
**Purpose:** Test email format validation  
**Row Count:** 20 rows (12 with invalid emails)  
**Use Cases:**
- TC-EMAIL-001: Double @@ symbol
- TC-EMAIL-002: Missing @ symbol
- TC-EMAIL-003: Missing TLD
- TC-EMAIL-005: Various invalid formats
- Email format edge cases

**Contents:**
- Row 1: john.smith@club.ie (valid)
- Row 2: sarah@@domain.com (invalid - double @@)
- Row 4: emily.davis (invalid - missing @)
- Row 5: @wilson.com (invalid - missing user)
- Row 6: jennifer@ (invalid - missing domain)
- Row 7: robert.domain.com (invalid - missing @)
- Row 8: linda anderson@club.ie (invalid - space)
- Row 9: james@.com (invalid - empty domain)
- Row 10: patricia@domain (invalid - missing TLD)
- Row 11: william@domain..com (invalid - double dot)
- Row 12: barbara@domain@example.com (invalid - double @)
- Row 13: richard@-domain.com (invalid - hyphen after @)
- Row 14: susan@.example.com (invalid - dot after @)
- Row 15: joseph@@@@example.com (invalid - multiple @@)
- Row 16: thomas@domain .com (invalid - space in domain)
- Row 17: charles..name@domain.com (valid - consecutive dots allowed)
- Row 18: karen@domain (at boundary - may be valid or invalid)
- Row 19: mark.davis@club.ie (valid)
- Row 20: steven.miller domain.com (invalid - missing @)

**Expected Result:**
- 12 rows marked "Invalid" with reason "Invalid email format"
- 8 rows marked valid
- Continue button disabled

---

### 5. `max_length_names.csv`
**Purpose:** Test handling of long names and special characters  
**Row Count:** 20 contacts  
**Use Cases:**
- TC-NORM-003: Special characters and accents preserved
- Edge cases: surnames with hyphens, apostrophes, accents
- Maximum field length validation

**Contents:**
- Row 1: Very long names (~50 chars): "Aaronjimenezlopezgarciamartinezrodriguez"
- Row 2: Very long names (~50 chars): "Benjaminantoniojosephugofranciscoalberto"
- Row 3: Jean-Paul, O'Brien (hyphens and apostrophes)
- Row 4: François, Müller (accented characters)
- Row 5: María, García (Spanish accents)
- Row 6: José, Martínez (Spanish accents)
- Row 7: Søren, Åkesson (Nordic characters)
- Row 8: Göran, Nilsson (Nordic characters)
- Row 9: Ève, Dubois (French accents)
- Row 10: Łukasz, Nowak (Polish characters)
- Row 11-14: Asian names (Yuki, Chen)
- Row 15-19: Various international characters

**Expected Result:**
- All rows marked valid
- Special characters and accents preserved in storage
- No truncation or encoding issues
- System handles UTF-8 correctly

---

### 6. `edge_cases.csv`
**Purpose:** Test data normalization and edge cases  
**Row Count:** 20 rows  
**Use Cases:**
- TC-NORM-001: Whitespace trimming
- TC-NORM-002: Email canonicalization
- TC-NORM-004: Boundary conditions
- Whitespace handling
- Mixed case emails

**Contents:**
- Row 1: john.smith@club.ie (baseline valid)
- Row 2: "  Sarah  " (leading/trailing spaces - to be trimmed)
- Row 3: MICHAEL.BROWN@CLUB.IE (uppercase email - canonicalized)
- Row 4: emily.davis (lowercase)
- Row 5: DAVID.WILSON@CLUB.IE (all caps)
- Row 6: jennifer+tag@club.ie (+tag in email)
- Row 7: robert_the_great, taylor-smith (names with special chars)
- Row 8: linda.anderson+test@club.ie (+ tag in email)
- Row 9: james.name.with.dots (multiple dots in name)
- Row 10: patricia.jackson123456789@club.ie (numbers in email)
- Row 11: w.w@club.ie (short email)
- Row 12: barbara789456123456@club.ie (long numeric email)
- Row 13: richard_underscore_martin (underscores)
- Row 14: susan.123@club.ie (numbers)
- Row 15: joseph@club.ie (short name)
- Row 16: thomas123robinson@club.ie (name with numbers)
- Row 17: charles2026@club.ie (year in email)
- Row 18: karen999@club.ie (numbers)
- Row 19: mark@sub.domain.club.ie (subdomain)
- Row 20: steven@club.co.uk (country TLD)

**Expected Result:**
- Whitespace trimmed automatically
- Email canonicalized to lowercase
- All rows valid after normalization
- Special chars (+, _, ., numbers) preserved where valid

---

### 7. `mixed_valid_invalid.csv`
**Purpose:** Test system behavior with mixed valid/invalid data  
**Row Count:** 20 rows (12 valid, 8 invalid)  
**Use Cases:**
- Real-world scenario: partial data quality
- Comprehensive validation testing
- Multiple error types in single file

**Contents:**
- Row 1: valid (john.smith@club.ie)
- Row 2: invalid (missing Last Name)
- Row 3: invalid (double @@ in email)
- Row 4: invalid (missing First Name)
- Row 5: valid (david.wilson@club.ie)
- Row 6: invalid (missing Email)
- Row 7: valid (robert.taylor@club.ie)
- Row 8: invalid (missing First Name)
- Row 9: invalid (missing Email)
- Row 10: valid (patricia.jackson@club.ie)
- Row 11: invalid (missing Email)
- Row 12: valid (barbara.harris@club.ie)
- Row 13: valid (richard.martin@club.ie)
- Row 14: invalid (missing Last Name)
- Row 15: valid (joseph.garcia@club.ie)
- Row 16: invalid (missing Last Name)
- Row 17: invalid (missing Email)
- Row 18: valid (karen.lewis@club.ie)
- Row 19: valid (mark.davis@club.ie)
- Row 20: invalid (all fields blank)

**Expected Result:**
- 12 rows valid
- 8 rows invalid with specific reasons
- Continue button disabled until all invalids resolved
- User must fix and re-upload

---

### 8. `large_file_500_rows.csv`
**Purpose:** Test performance and row limit boundaries  
**Row Count:** 500 valid contacts  
**Use Cases:**
- TC-LIMIT-002: Exact row limit (1000) at baseline
- TC-LIMIT-007: Performance validation (<10 seconds)
- Scalability testing
- Load testing

**Contents:**
- 500 sequentially numbered, unique valid contacts
- Format: "FirstName###, LastName, firstname###@club.ie"
- All records valid for baseline performance
- No special cases or errors
- Suitable for mass import testing

**Expected Result:**
- File parses in <10 seconds
- All 500 rows valid
- Progress indicator shown during validation
- No timeout or performance degradation
- UI remains responsive

---

## Usage Guide

### For Manual QA Testing

**Step 1: Select Test Data File**
```
Check the test case ID in manual_test_cases.md
Match to corresponding CSV file in test_data/
```

**Step 2: Upload and Validate**
```
1. Navigate to Bulk Import Contacts > Step 1
2. Upload selected CSV file
3. Observe:
   - Parse success/failure
   - Invalid row count
   - Error messages
   - Time to validate
```

**Step 3: Verify Expected Results**
```
Compare actual results to "Expected Result" in file description
Document any discrepancies
```

### For Automated Testing

**Using in Test Frameworks:**
```python
# Pytest example
from pathlib import Path

TEST_DATA_DIR = Path(__file__).parent / 'test_data'

@pytest.mark.parametrize('csv_file,expected_invalids', [
    (TEST_DATA_DIR / 'valid_contacts.csv', 0),
    (TEST_DATA_DIR / 'invalid_emails.csv', 12),
    (TEST_DATA_DIR / 'missing_required_fields.csv', 7),
    (TEST_DATA_DIR / 'duplicate_contacts.csv', 5),
])
def test_csv_validation(csv_file, expected_invalids):
    result = upload_and_validate(csv_file)
    assert result.invalid_count == expected_invalids
```

### For Integration Testing

1. Use `valid_contacts.csv` for baseline happy path
2. Use `mixed_valid_invalid.csv` for realistic scenarios
3. Use `large_file_500_rows.csv` for performance benchmarks
4. Use specific files (`invalid_emails.csv`, etc.) for edge case validation

---

## Test Data Matrix

| File | Valid Rows | Invalid Rows | Duplicates | Scenario | Priority |
|------|-----------|-------------|-----------|----------|----------|
| valid_contacts.csv | 20 | 0 | 0 | Happy path | CRITICAL |
| duplicate_contacts.csv | 15 | 0 | 5 | In-file dedup | HIGH |
| missing_required_fields.csv | 13 | 7 | 0 | Required field validation | HIGH |
| invalid_emails.csv | 8 | 12 | 0 | Email format validation | HIGH |
| max_length_names.csv | 20 | 0 | 0 | Special characters | MEDIUM |
| edge_cases.csv | 20 | 0 | 0 | Normalization | MEDIUM |
| mixed_valid_invalid.csv | 12 | 8 | 0 | Real-world scenario | HIGH |
| large_file_500_rows.csv | 500 | 0 | 0 | Performance testing | MEDIUM |

---

## Creating Custom Test Data

### CSV Format Rules

```csv
First Name,Last Name,Email
John,Smith,john@club.ie
```

**Requirements:**
- Header row MUST be present (row 1)
- Exactly 3 columns: First Name, Last Name, Email
- UTF-8 encoding (with or without BOM)
- No special delimiters (comma-separated only)
- No quotes around fields unless commas present
- Max 1000 rows (data)
- Max 10 MB file size

### Template for Custom Files

```csv
First Name,Last Name,Email
[test_name],[test_surname],[test_email@domain.ie]
```

**Examples:**
- Valid: `John,Smith,john@club.ie`
- Valid: `Jean-Paul,O'Brien,jeanpaul@club.ie`
- Valid: `María,García,maria@club.ie`
- Invalid: `John,,john@club.ie` (missing Last Name)
- Invalid: `John,Smith,john@domain` (invalid email)

---

## File Size and Performance Reference

| File | Size | Rows | Parse Time | Notes |
|------|------|------|-----------|-------|
| valid_contacts.csv | ~750 B | 20 | <100 ms | Immediate |
| duplicate_contacts.csv | ~750 B | 20 | <100 ms | Immediate |
| missing_required_fields.csv | ~700 B | 20 | <100 ms | Immediate |
| invalid_emails.csv | ~750 B | 20 | <100 ms | Immediate |
| max_length_names.csv | ~1.2 KB | 20 | <150 ms | Low overhead |
| edge_cases.csv | ~1 KB | 20 | <150 ms | Normalization |
| mixed_valid_invalid.csv | ~700 B | 20 | <100 ms | Immediate |
| large_file_500_rows.csv | ~25 KB | 500 | <1 second | Baseline perf |

---

## Test Data Maintenance

### Updating Test Data

If test scenarios change:
1. Update corresponding CSV file with new data
2. Update row count and invalid count in this README
3. Update expected results in manual_test_cases.md
4. Version the file: `filename_v2.csv`

### Adding New Test Data

To create new test scenarios:
1. Document the scenario and use case
2. Create CSV file with descriptive name
3. Add entry to Test Data Matrix
4. Link corresponding test cases in manual_test_cases.md
5. Update this README

### Backup & Version Control

- All test data in `/test_data/` is version controlled
- Commit changes with reference to test case IDs
- Maintain backward compatibility for automated tests

---

## Common Pitfalls

### ❌ Incorrect CSV Format
```csv
First Name | Last Name | Email      ← Wrong delimiter (pipe)
John;Smith;john@club.ie             ← Wrong delimiter (semicolon)
```

### ✅ Correct Format
```csv
First Name,Last Name,Email
John,Smith,john@club.ie
```

### ❌ Encoding Issues
- File saved as ISO-8859-1 or Windows-1252
- BOM stripped incorrectly

### ✅ Correct Encoding
- Save as UTF-8 (with or without BOM)
- Validate special characters display correctly

### ❌ Whitespace Issues
```csv
First Name,Last Name,Email
 John , Smith , john@club.ie  ← Spaces not trimmed
```

### ✅ Correct Whitespace
```csv
First Name,Last Name,Email
John,Smith,john@club.ie
```

---

## Support & Questions

For issues or clarifications:
1. Review the QA Specification (docs/qa_specification.md)
2. Check Manual Test Cases (docs/manual_test_cases.md)
3. Verify against this Test Data Reference
4. Consult the BRD (brd/bulk_contacts_brd.txt)

---

**Document Version:** 1.0  
**Last Updated:** 11 March 2026  
**Status:** Ready for QA Use
