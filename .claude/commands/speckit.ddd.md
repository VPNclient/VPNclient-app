# Document-Driven Development Sync (Speckit <-> DDD)

You are facilitating the synchronization between the High-Level Architecture (managed by `speckit` in the Meta-Project) and Low-Level Implementation (managed by `ddd` in Sub-Projects).

## Context
- **Meta-Project:** Contains `specs/` defining "WHAT" and "WHY".
- **Sub-Projects:** Defined in `CLAUDE.md` and visible as `taxlien-*/` directories. Contain `flows/ddd-*/` defining "HOW" and client documentation.

## Command: $ARGUMENTS

### Mode 1: Auto-Sync (No Arguments)
If `$ARGUMENTS` is empty, perform a full project synchronization scan:

1.  **Discovery:**
    - Identify valid **Sub-Project Paths** (directories starting with `taxlien-`).
    - List all specification files in `specs/` (Meta-Project).
    - For each Sub-Project, list all directories in `flows/` (Sub-Project).

2.  **Analysis & Execution Loop:**
    Iterate through every Feature/Spec found:

    **A. New Features (Create):**
    - **Condition:** A spec exists in `specs/` (e.g., `005-auth.md`) but no corresponding `flows/ddd-auth` exists in any sub-project.
    - **Action:**
        1.  Ask User: "Found new spec 'auth'. Which sub-project should this go to? (or skip)"
        2.  **If approved:** Run **Push** logic to initialize the flow.

    **B. Updates (Push):**
    - **Condition:** Spec exists AND Sub-Project flow exists.
    - **Action:**
        1.  Read the Meta-Project Spec and the Sub-Project `01-requirements.md`.
        2.  If the Meta-Spec has content not present in the Sub-Project (updated requirements):
            - **Perform Update Automatically:** Overwrite/Update `01-requirements.md` in the sub-project with the new spec content.
            - Notify User: "Synced updates for [feature] to [sub-project]."

    **C. Findings (Pull):**
    - **Condition:** Sub-Project flow exists.
    - **Action:**
        1.  Read Sub-Project `04-implementation-log.md` and `_status.md`.
        2.  Look for explicit "Blockers", "Constraints Discovered", or "Design Changes" sections.
        3.  **If significant new info found:**
            - Ask User: "Sub-project [name] has new implementation findings for [feature]. Pull to main spec? (y/n)"
            - **If approved:** Run **Pull** logic.

    **D. Documentation Sync:**
    - **Condition:** Sub-Project has completed `README.md` in `flows/ddd-[feature]/`.
    - **Action:**
        1.  Check if Meta-Project has client-facing documentation section.
        2.  Ask User: "Feature [name] has client documentation. Pull to meta-project? (y/n)"
        3.  **If approved:** Copy simplified documentation to meta-project spec as "Client Overview" section.

---

### Mode 2: Manual Direction
If `$ARGUMENTS` contains arguments, parse as: `[direction] [feature_name] [subproject_path]`

#### 1. Push (Meta -> Sub)
**Goal:** Transfer architectural requirements to implementation context.
**Command:** `/speckit.ddd push <feature> <subproject_path>`

**Steps:**
1.  **Read Source:** Read `specs/*-<feature>.md` (or similar).
2.  **Read Target:** Check if `flows/ddd-<feature>/` exists in `<subproject_path>`.
3.  **Action:**
    - If new: Initialize `flows/ddd-<feature>/01-requirements.md` in the sub-project using content from the Spec.
    - If existing: Update `flows/ddd-<feature>/01-requirements.md` with latest Spec content.
    - Convert "System Requirements" from Spec to "User Stories" format if needed.

#### 2. Pull (Sub -> Meta)
**Goal:** Update architecture with implementation realities and client documentation.
**Command:** `/speckit.ddd pull <feature> <subproject_path>`

**Steps:**
1.  **Read Source:** Read `flows/ddd-<feature>/04-implementation-log.md`, `02-specifications.md`, and `README.md` in `<subproject_path>`.
2.  **Read Target:** Read `specs/*-<feature>.md`.
3.  **Action:**
    - Append/Update a "Implementation Notes" or "Technical Constraints" section in the Meta-Spec.
    - **If README.md exists:** Append/Update a "Client Overview" section with simplified documentation.
    - **Do not** overwrite business goals.

#### 3. Status
**Goal:** Check alignment.
**Command:** `/speckit.ddd status <feature>`

**Steps:**
1.  Compare the Spec in Meta-Project vs the DDD flow in Sub-Projects.
2.  Report sync status including documentation completion.
3.  Show which phases are complete (Requirements → Specifications → Plan → Implementation → Documentation).
