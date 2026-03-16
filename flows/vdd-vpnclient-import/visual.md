# Visual Mockups: [FEATURE_NAME]

> Version: 1.0
> Status: DRAFT | REVIEW | APPROVED
> Last Updated: [DATE]

## Overview

ASCII mockups and visual flows to align on the feature's appearance and user experience before technical specification.

---

## Screen: [Screen Name]

[Description of what this screen does]

```
+--------------------------------------------------+
|  = HEADER / TITLE                                |
+--------------------------------------------------+
|                                                  |
|  [Section Label]                                 |
|  +--------------------------------------------+  |
|  |                                            |  |
|  |   Main Content Area                        |  |
|  |                                            |  |
|  |   [Button]  (O) Option                     |  |
|  |                                            |  |
|  +--------------------------------------------+  |
|                                                  |
|  Label: ____________  [Action Button]            |
|  * Required field                                |
+--------------------------------------------------+
|  ~ Status bar / footer                           |
+--------------------------------------------------+
```

### Elements

| Symbol | Meaning |
|--------|---------|
| `=` | Header/Title |
| `-` | Divider/Separator |
| `|` | Container edge |
| `[ ]` | Button/Input |
| `(O)` | Radio/Checkbox |
| `*` | Required indicator |
| `~` | Text area/Scrollable |

### States

#### Empty State

```
+------------------+
|  = Screen Title  |
+------------------+
|                  |
|     (icon)       |
|  No items yet    |
|  [Create New]    |
|                  |
+------------------+
```

#### Loading State

```
+------------------+
|  = Screen Title  |
+------------------+
|  Loading...      |
|  [=====>    ]    |
|                  |
+------------------+
```

#### Error State

```
+------------------+
|  = Screen Title  |
+------------------+
|  ! Error         |
|  Something went  |
|  wrong.          |
|  [Retry] [Cancel]|
+------------------+
```

---

## Flow: [User Flow Name]

Navigation between screens:

```
[Screen A] --(action)--> [Screen B] --(action)--> [Screen C]
     ^                                              |
     |______________(cancel)________________________|
```

### Step-by-Step

1. **Screen A**: User starts here
   - Action: Clicks "Next"
   - Result: Navigates to Screen B

2. **Screen B**: User does something
   - Action: Completes task
   - Result: Navigates to Screen C

3. **Screen C**: Completion
   - Action: Can cancel and return to A

---

## Component: [Component Name]

[Description of reusable component]

```
+--------------------------------+
|  = Component Title             |
+--------------------------------+
|  [Item 1]           [Action]   |
|  ----------------------------- |
|  [Item 2]           [Action]   |
|  ----------------------------- |
|  [Item 3]           [Action]   |
+--------------------------------+
```

---

## Notes

- [Design considerations]
- [User preferences noted]
- [Accessibility considerations]

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
