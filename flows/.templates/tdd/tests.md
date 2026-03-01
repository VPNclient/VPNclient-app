# Test Cases: [FEATURE_NAME]

> Version: 1.0
> Status: DRAFT | REVIEW | APPROVED
> Last Updated: [DATE]

## Overview

Test cases defined in simple format (Given/When/Then) before technical specification. Each test maps to a requirement.

---

## Test: [Test Name]

**ID**: T001
**Requirement**: [Link to requirement ID]
**Type**: Functional | Edge Case | Error | Integration

### Scenario

**Given**: [Initial state/preconditions]
**When**: [Action or event]
**Then**: [Expected outcome]

### Examples

| Input | Expected Output |
|-------|-----------------|
| [value1] | [result1] |
| [value2] | [result2] |

### Edge Cases

- [Special condition 1]
- [Special condition 2]

---

## Test: [Test Name]

**ID**: T002
**Requirement**: [Link to requirement ID]
**Type**: Functional | Edge Case | Error | Integration

### Scenario

**Given**: [Initial state/preconditions]
**When**: [Action or event]
**Then**: [Expected outcome]

### Examples

| Input | Expected Output |
|-------|-----------------|
| [value1] | [result1] |

---

## Integration Flow: [Flow Name]

End-to-end test across multiple components:

```
[Step 1] --> [Step 2] --> [Step 3] --> [Result]
```

### Scenario

**Given**: [Initial system state]
**When**: [User completes full flow]
**Then**: [Final expected state]

### Steps

1. [Action at step 1]
2. [Action at step 2]
3. [Action at step 3]
4. [Verify result]

---

## Error Scenarios

### Test: [Error Case Name]

**ID**: E001
**Requirement**: [Link to requirement ID]

**Given**: [Precondition that leads to error]
**When**: [Action that triggers error]
**Then**: 
- System displays error message: "[message]"
- System state remains unchanged
- User can [recovery action]

---

## Test Coverage Matrix

| Requirement ID | Test IDs | Status |
|----------------|----------|--------|
| R001 | T001, T002 | Covered |
| R002 | T003 | Covered |
| R003 | - | Not Covered |

---

## Notes

- [Testing considerations]
- [Assumptions made]
- [Dependencies on external systems]

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
