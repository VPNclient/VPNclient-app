# Document-Driven Development (DDD) Flow

## Overview

DDD treats documentation as the primary development artifact, encompassing not just specifications but the complete development lifecycle: requirements, specifications, implementation plans, and client-facing documentation. Code is the "last-mile" implementation derived from well-defined documents. This enables:

- **Resumability**: Continue work across sessions without context loss
- **Traceability**: Every implementation decision traces back to requirements
- **Iteration**: Refine documents before committing to code
- **Parallelization**: Multiple agents can work from the same documents
- **Client Communication**: Clear, accessible documentation for stakeholders

## Flow Phases

```
REQUIREMENTS → SPECIFICATIONS → PLAN → IMPLEMENTATION → DOCUMENTATION
     ↑              ↑            ↑           ↑                ↑
     └──────────────┴────────────┴───────────┴────────────────┘ (iterate at any phase)
```

### Phase 1: Requirements

**Input**: User describes the feature/change they want
**Output**: `flows/ddd-[name]/01-requirements.md`

Requirements capture the **what** and **why**:
- Problem being solved
- User stories (As a... I want... So that...)
- Acceptance criteria (Given/When/Then)
- Constraints and non-goals
- Open questions

### Phase 2: Specifications

**Input**: Reviewed requirements
**Output**: `flows/ddd-[name]/02-specifications.md`

Specifications add the **how** at architectural level:
- Affected systems/components
- Data models and interfaces
- Behavior descriptions
- Edge cases and error handling
- Dependencies and integration points

### Phase 3: Plan

**Input**: Approved specifications
**Output**: `flows/ddd-[name]/03-plan.md`

Plan breaks down into actionable implementation:
- Task breakdown with dependencies
- File changes (create/modify/delete)
- Testing strategy
- Rollback considerations
- Estimated complexity per task

### Phase 4: Implementation

**Input**: Approved plan
**Output**: Working code + `flows/ddd-[name]/04-implementation-log.md`

Implementation executes the plan:
- Track progress against plan
- Document deviations and why
- Capture learnings for spec refinement

### Phase 5: Documentation

**Input**: Completed implementation
**Output**: `flows/ddd-[name]/README.md`

Client-facing documentation explains the feature in simple terms:
- **What it does**: Feature functionality in plain language
- **How it works**: Simple, non-technical explanation ("on your fingers")
- **Usage examples**: Basic examples showing typical use cases
- **Benefits**: Key advantages for the end user/client

This phase bridges technical implementation with client understanding.

---

## Directory Structure

```
flows/
├── ddd.md                      # This file (flow reference)
├── .templates/                 # Templates for new documents
│   ├── requirements.md
│   ├── specifications.md
│   ├── plan.md
│   ├── implementation-log.md
│   └── readme.md               # NEW: Client documentation template
└── ddd-[feature-name]/         # Per-feature document directory
    ├── 01-requirements.md
    ├── 02-specifications.md
    ├── 03-plan.md
    ├── 04-implementation-log.md
    ├── README.md               # NEW: Client-facing documentation
    └── _status.md              # Current phase + blockers
```

---

## Starting a New DDD Flow

### New Feature
```
/ddd start [feature-name]
```

Creates `flows/ddd-[feature-name]/` with templates and opens requirements phase.

### Resume Existing
```
/ddd resume [feature-name]
```

Reads `_status.md` to determine current phase and continues from there.

### Fork (Context Recovery)
```
/ddd fork [existing-name] [new-name]
```

When context is lost or pivoting: creates new document dir copying existing artifacts as starting point, with `_status.md` noting the fork.

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

### Implementation → Documentation
- [ ] Implementation complete and tested
- [ ] All planned features working
- [ ] Ready for client communication
- [ ] User approves documentation phase: "ready for docs"

---

## Status Tracking

Each document dir has `_status.md`:

```markdown
# Status: ddd-[name]

## Current Phase
DOCUMENTATION (in progress)

## Last Updated
2024-12-22 by Claude

## Blockers
- None

## Progress
- [x] Requirements drafted
- [x] Requirements approved
- [x] Specifications drafted
- [x] Specifications approved
- [x] Plan drafted
- [x] Plan approved
- [x] Implementation started
- [x] Implementation complete
- [ ] Documentation drafted  ← current
- [ ] Documentation approved

## Context Notes
Key decisions or context for resuming:
- Decided to use X approach because Y
- User prefers Z over W
- Client needs simple examples without technical jargon
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

DDD follows CLAUDE.md principles:
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
- **Missing client documentation**: Skipping README phase leaves clients without understanding
- **Technical jargon in README**: Using complex terms instead of simple explanations
