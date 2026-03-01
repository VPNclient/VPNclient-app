# Visual-Driven Development (VDD) Flow

## Overview

VDD extends Document-Driven Development by adding a **Visual phase** between Requirements and Specifications. This phase uses simple ASCII representations to align on UI/UX, layouts, and visual flows before any technical specification is written. This enables:

- **Visual Alignment**: Stakeholders can "see" the feature before implementation
- **Early Feedback**: Catch UX issues before code is written
- **Simple Communication**: ASCII art is universal and requires no design tools
- **Traceability**: Visual mockups link requirements to technical specs
- **Resumability**: Visual context preserved across sessions

## Flow Phases

```
REQUIREMENTS → VISUAL → SPECIFICATIONS → PLAN → IMPLEMENTATION → DOCUMENTATION
     ↑          ↑         ↑            ↑           ↑                ↑
     └──────────┴─────────┴────────────┴───────────┴────────────────┘ (iterate at any phase)
```

### Phase 1: Requirements

**Input**: User describes the feature/change they want
**Output**: `flows/vdd-[name]/01-requirements.md`

Requirements capture the **what** and **why**:
- Problem being solved
- User stories (As a... I want... So that...)
- Acceptance criteria (Given/When/Then)
- Constraints and non-goals
- Open questions

### Phase 2: Visual (VDD-specific)

**Input**: Approved requirements
**Output**: `flows/vdd-[name]/02-visual.md`

Visual phase creates **ASCII mockups** to align on appearance:
- Screen layouts using simple characters (`+`, `-`, `|`, `=`)
- Component placement and sizing
- Navigation flows (screen → screen)
- Button/text placement
- Data display formats (tables, lists, cards)
- State representations (empty, loading, error, success)

**ASCII Conventions:**
```
+------------------+     = Header/Title
|   Title Here     |     - Divider/Separator
+------------------+     | Container edge
|  [Button]  (O)   |     [ ] Input field/button
|  Label: _____    |     (O) Radio/checkbox
|  * Required      |     * Required indicator
+------------------+     ~ Text area
| ~~~~~~~~~~~~~~~~ |
+------------------+
```

### Phase 3: Specifications

**Input**: Approved visual mockups
**Output**: `flows/vdd-[name]/03-specifications.md`

Specifications add the **how** at architectural level, informed by visual layout:
- Affected systems/components
- Data models and interfaces
- Behavior descriptions
- Edge cases and error handling
- Dependencies and integration points
- **Visual constraints** from approved mockups

### Phase 4: Plan

**Input**: Approved specifications
**Output**: `flows/vdd-[name]/04-plan.md`

Plan breaks down into actionable implementation:
- Task breakdown with dependencies
- File changes (create/modify/delete)
- Testing strategy
- Rollback considerations
- Estimated complexity per task

### Phase 5: Implementation

**Input**: Approved plan
**Output**: Working code + `flows/vdd-[name]/05-implementation-log.md`

Implementation executes the plan:
- Track progress against plan
- Document deviations and why
- Capture learnings for spec refinement

### Phase 6: Documentation

**Input**: Completed implementation
**Output**: `flows/vdd-[name]/README.md`

Client-facing documentation explains the feature in simple terms:
- **What it does**: Feature functionality in plain language
- **How it works**: Simple, non-technical explanation ("on your fingers")
- **Usage examples**: Basic examples showing typical use cases
- **Benefits**: Key advantages for the end user/client

---

## Directory Structure

```
flows/
├── vdd.md                      # This file (flow reference)
├── .templates/
│   ├── requirements.md
│   ├── visual.md               # NEW: ASCII mockup template
│   ├── specifications.md
│   ├── plan.md
│   ├── implementation-log.md
│   └── readme.md
└── vdd-[feature-name]/         # Per-feature document directory
    ├── 01-requirements.md
    ├── 02-visual.md            # NEW: ASCII visual mockups
    ├── 03-specifications.md
    ├── 04-plan.md
    ├── 05-implementation-log.md
    ├── README.md
    └── _status.md              # Current phase + blockers
```

---

## Starting a New VDD Flow

### New Feature
```
/vdd start [feature-name]
```

Creates `flows/vdd-[feature-name]/` with templates and opens requirements phase.

### Resume Existing
```
/vdd resume [feature-name]
```

Reads `_status.md` to determine current phase and continues from there.

### Fork (Context Recovery)
```
/vdd fork [existing-name] [new-name]
```

When context is lost or pivoting: creates new document dir copying existing artifacts as starting point, with `_status.md` noting the fork.

---

## Phase Transitions

### Requirements → Visual
- [ ] Requirements reviewed by user
- [ ] Open questions resolved
- [ ] Scope clearly bounded
- [ ] User explicitly approves: "requirements approved"

### Visual → Specifications
- [ ] ASCII mockups reviewed by user
- [ ] All screens/states represented
- [ ] Layout and navigation clear
- [ ] User explicitly approves: "visual approved"

### Specifications → Plan
- [ ] Specifications reviewed by user
- [ ] All affected systems identified
- [ ] Edge cases documented
- [ ] User explicitly approves: "specs approved"

### Plan → Implementation
- [ ] Plan reviewed by user
- [ ] Tasks are atomic and testable
- [ ] Dependencies mapped
- [ ] User explicitly approves: "plan approved"

### Implementation → Documentation
- [ ] Implementation complete and tested
- [ ] All planned features working
- [ ] Ready for client communication
- [ ] User approves documentation phase: "ready for docs"

---

## Status Tracking

Each document dir has `_status.md`:

```markdown
# Status: vdd-[name]

## Current Phase
VISUAL (in progress)

## Last Updated
2024-12-22 by Claude

## Blockers
- None

## Progress
- [x] Requirements drafted
- [x] Requirements approved
- [x] Visual mockups drafted  ← current
- [ ] Visual approved
- [ ] Specifications drafted
- [ ] Specifications approved
- [ ] Plan drafted
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete
- [ ] Documentation drafted
- [ ] Documentation approved

## Context Notes
Key decisions or context for resuming:
- User prefers compact layout with sidebar navigation
- ASCII mockup approved for main screen, need to add error states
```

---

## Iteration Protocol

At any phase, user can request changes:

1. **Minor adjustment**: Agent modifies current document in place
2. **Major pivot**: Fork to new document dir with adjusted requirements
3. **Scope change**: Go back to requirements phase

After each iteration:
- Update `_status.md` with what changed and why
- Increment version in document header if major change

---

## Session Handoff

When ending a session mid-flow:

1. Update `_status.md` with current state
2. Document any in-flight reasoning
3. List explicit next steps
4. Note any context that might be lost

New session reads `_status.md` first to reconstruct context.

---

## Integration with CLAUDE.md

VDD follows CLAUDE.md principles:
- **Explicit predictions**: State expected outcomes before implementation
- **Checkpoints**: Verify after each task, not batch
- **One test at a time**: During implementation phase
- **Autonomy boundaries**: Phase transitions require user approval

---

## Anti-Patterns

- **Skipping visual phase**: Defeats the purpose of VDD
- **Overly complex ASCII**: Keep it simple and readable
- **Vague requirements**: "Make it pretty" → ask clarifying questions
- **Premature implementation**: Writing code before visual approval
- **Silent pivots**: Changing scope without updating artifacts
- **Stale status**: Forgetting to update `_status.md`
- **Missing states**: Only showing happy path, not error/empty/loading states
- **Ignoring approved visuals**: Implementation deviates from approved mockups
