# Spec-Driven Development (SDD) Flow

## Overview

SDD treats specifications as the primary development artifact. Code is the "last-mile" implementation derived from well-defined specs. This enables:

- **Resumability**: Continue work across sessions without context loss
- **Traceability**: Every implementation decision traces back to requirements
- **Iteration**: Refine specs before committing to code
- **Parallelization**: Multiple agents can work from the same spec

## Flow Phases

```
REQUIREMENTS → SPECIFICATIONS → PLAN → IMPLEMENTATION
     ↑              ↑            ↑
     └──────────────┴────────────┴── (iterate at any phase)
```

### Phase 1: Requirements

**Input**: User describes the feature/change they want  
**Output**: `flows/sdd-[name]/01-requirements.md`

Requirements capture the **what** and **why**:
- Problem being solved
- User stories (As a... I want... So that...)
- Acceptance criteria (Given/When/Then)
- Constraints and non-goals
- Open questions

### Phase 2: Specifications

**Input**: Reviewed requirements  
**Output**: `flows/sdd-[name]/02-specifications.md`

Specifications add the **how** at architectural level:
- Affected systems/components
- Data models and interfaces
- Behavior descriptions
- Edge cases and error handling
- Dependencies and integration points

### Phase 3: Plan

**Input**: Approved specifications  
**Output**: `flows/sdd-[name]/03-plan.md`

Plan breaks down into actionable implementation:
- Task breakdown with dependencies
- File changes (create/modify/delete)
- Testing strategy
- Rollback considerations
- Estimated complexity per task

### Phase 4: Implementation

**Input**: Approved plan  
**Output**: Working code + `flows/sdd-[name]/04-implementation-log.md`

Implementation executes the plan:
- Track progress against plan
- Document deviations and why
- Capture learnings for spec refinement

---

## Directory Structure

```
flows/
├── sdd.md                      # This file (flow reference)
├── .templates/                 # Templates for new specs
│   ├── requirements.md
│   ├── specifications.md
│   ├── plan.md
│   └── implementation-log.md
└── sdd-[feature-name]/         # Per-feature spec directory
    ├── 01-requirements.md
    ├── 02-specifications.md
    ├── 03-plan.md
    ├── 04-implementation-log.md
    └── _status.md              # Current phase + blockers
```

---

## Starting a New SDD Flow

### New Feature
```
/sdd start [feature-name]
```

Creates `flows/sdd-[feature-name]/` with templates and opens requirements phase.

### Resume Existing
```
/sdd resume [feature-name]
```

Reads `_status.md` to determine current phase and continues from there.

### Fork (Context Recovery)
```
/sdd fork [existing-name] [new-name]
```

When context is lost or pivoting: creates new spec dir copying existing artifacts as starting point, with `_status.md` noting the fork.

---

## Phase Transitions

### Requirements → Specifications
- [ ] Requirements reviewed by user
- [ ] Open questions resolved
- [ ] Scope clearly bounded
- [ ] User explicitly approves: "requirements approved"

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

---

## Status Tracking

Each spec dir has `_status.md`:

```markdown
# Status: sdd-[name]

## Current Phase
SPECIFICATIONS (awaiting review)

## Last Updated
2024-12-22 by Claude

## Blockers
- Waiting for Q to clarify X

## Progress
- [x] Requirements drafted
- [x] Requirements approved
- [ ] Specifications drafted  ← current
- [ ] Specifications approved
- [ ] Plan drafted
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete

## Context Notes
Key decisions or context for resuming:
- Decided to use X approach because Y
- Q prefers Z over W
```

---

## Iteration Protocol

At any phase, user can request changes:

1. **Minor adjustment**: Agent modifies current document in place
2. **Major pivot**: Fork to new spec dir with adjusted requirements
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

SDD follows CLAUDE.md principles:
- **Explicit predictions**: State expected outcomes before implementation
- **Checkpoints**: Verify after each task, not batch
- **One test at a time**: During implementation phase
- **Autonomy boundaries**: Phase transitions require user approval

---

## Anti-Patterns

- **Skipping phases**: Each phase catches different classes of errors
- **Vague requirements**: "Make it better" → ask clarifying questions
- **Premature implementation**: Writing code before plan approval
- **Silent pivots**: Changing scope without updating artifacts
- **Stale status**: Forgetting to update `_status.md`
