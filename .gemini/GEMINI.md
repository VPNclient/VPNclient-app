# Project Context: Tax Lien Investment Platform (Meta-Project)

## Overview
This is the **Meta-Project** for the Tax Lien Investment Platform. It serves as the architectural headquarters. 

**CRITICAL:** No implementation code exists in this root repository. All code resides in specialized Sub-Projects (separate repositories/folders).

## Workflow: Spec-Driven Development (SDD)

We use a strict **Spec-Driven Development** workflow separated into two layers:

### 1. Architecture Layer (Meta-Project)
- **Tool:** `/speckit`
- **Location:** `specs/`
- **Focus:** High-level architecture, Business Logic, Data Flow, Cross-module dependencies.
- **Goal:** Define **WHAT** we are building and **WHY**.
- **Process:**
    1.  `/speckit.specify`: Draft initial requirements.
    2.  `/speckit.clarify`: Refine and de-risk.
    3.  `/speckit.plan`: Define the technical architecture and sub-project responsibilities.

### 2. Implementation Layer (Sub-Projects)
- **Tool:** `/sdd` (running inside sub-project folders)
- **Location:** `<subproject>/flows/sdd-*/`
- **Focus:** Low-level design, Class/Function structure, Code implementation, Testing.
- **Goal:** Define **HOW** to build it and execute.
- **Process:**
    1.  Receive context via `/speckit.sdd push`.
    2.  Run `/sdd start`: Initialize local flow.
    3.  Iterate through Requirements -> Specs -> Plan -> Implementation locally.
    4.  Report back via `/speckit.sdd pull`.

## Bridge: `/speckit.sdd`

This command synchronizes the two layers.

- **Push (`/speckit.sdd push`)**: Transmits approved architecture from Meta-Project to Sub-Project to kickstart implementation.
- **Pull (`/speckit.sdd pull`)**: Feeds implementation discoveries (constraints, edge cases, refactorings) back into the Meta-Project architecture to keep the "Truth" updated.

## Sub-Projects Map
*(Maintain a list of active sub-projects here)*
- `taxlien-sdd` (Current Meta-Repo)
- `taxlien-parser` (Data ingestion)
- `taxlien-gateway` (API Gateway)
- `taxlien-ml` (Machine Learning models)
- `taxlien-flutter-app` (Mobile/Web Client)

## Core Mandates
1.  **Never implement code in the Meta-Project.**
2.  **Always update Specs in Meta-Project** when implementation diverges significantly.
3.  Use `/speckit` for high-level decisions.
4.  Use `/sdd` for code-level execution.
