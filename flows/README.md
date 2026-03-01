# VPN Client - Development Flows Master Guide

> Version: 1.0
> Last Updated: 2026-03-01
> Status: ACTIVE

## Overview

This project uses **Document-Driven Development (DDD)** with specialized flows for different aspects:

| Flow | Purpose | When to Use | Command |
|------|---------|-------------|---------|
| **DDD** | Document-Driven Development | New features, major changes | `/ddd` |
| **TDD** | Tests-Driven Development | Adding tests, test coverage | `/tdd` |
| **VDD** | Visual-Driven Development | UI/UX changes, new screens | `/vdd` |
| **SDD** | Spec-Driven Development | Technical specifications | `/sdd` |

## Quick Start

### Starting a New Flow

```bash
# Start new feature documentation
/ddd start feature-name

# Start new test flow
/tdd start feature-name

# Start new UI/UX flow
/vdd start feature-name

# Start new spec flow
/sdd start feature-name
```

### Resuming Existing Flow

```bash
# Resume existing flow
/ddd resume feature-name
/tdd resume feature-name
/vdd resume feature-name
/sdd resume feature-name
```

### Checking Status

```bash
# Show all active flows
/ddd status
/tdd status
/vdd status
/sdd status
```

---

## Flow Directory Structure

```
flows/
├── ddd.md                      # DDD flow reference
├── tdd.md                      # TDD flow reference
├── vdd.md                      # VDD flow reference
├── sdd.md                      # SDD flow reference
├── .templates/                 # Templates for new flows
│   ├── ddd/                    # DDD templates
│   ├── tdd/                    # TDD templates
│   ├── vdd/                    # VDD templates
│   └── sdd/                    # SDD templates
├── ddd-[feature]/              # DDD feature directories
│   ├── 01-requirements.md
│   ├── 02-specifications.md
│   ├── 03-plan.md
│   ├── 04-implementation-log.md
│   ├── README.md               # Client-facing docs
│   └── _status.md              # Current phase
├── tdd-[feature]/              # TDD feature directories
│   ├── 01-requirements.md
│   ├── 02-tests.md
│   ├── 03-specifications.md
│   ├── 04-plan.md
│   ├── 05-implementation-log.md
│   ├── README.md
│   └── _status.md
└── vdd-[feature]/              # VDD feature directories
    ├── 01-requirements.md
    ├── 02-visual.md
    ├── 03-specifications.md
    ├── 04-plan.md
    ├── 05-implementation-log.md
    ├── README.md
    └── _status.md
```

---

## Active Flows

### Completed DDD Flows

| Feature | Status | Documentation |
|---------|--------|---------------|
| **ConfigService** | ✅ Complete | [flows/ddd-config-service/](./ddd-config-service/) |
| **Onboarding System** | ✅ Complete | [flows/ddd-onboarding/](./ddd-onboarding/) |

### Completed TDD Flows

| Feature | Status | Documentation |
|---------|--------|---------------|
| **ConfigService Tests** | 🟡 Tests Defined | [flows/tdd-config-service/](./tdd-config-service/) |

### Completed VDD Flows

| Feature | Status | Documentation |
|---------|--------|---------------|
| **Main UI Screens** | 🟡 Visual Defined | [flows/vdd-main-ui/](./vdd-main-ui/) |

---

## Flow Phases

### DDD Phases

```
REQUIREMENTS → SPECIFICATIONS → PLAN → IMPLEMENTATION → DOCUMENTATION
     ↑              ↑            ↑           ↑                ↑
     └──────────────┴────────────┴───────────┴────────────────┘ (iterate)
```

### TDD Phases

```
REQUIREMENTS → TESTS → SPECIFICATIONS → PLAN → IMPLEMENTATION → DOCUMENTATION
     ↑          ↑        ↑            ↑           ↑                ↑
     └──────────┴────────┴────────────┴───────────┴────────────────┘ (iterate)
```

### VDD Phases

```
REQUIREMENTS → VISUAL → SPECIFICATIONS → PLAN → IMPLEMENTATION → DOCUMENTATION
     ↑          ↑         ↑            ↑           ↑                ↑
     └──────────┴─────────┴────────────┴───────────┴────────────────┘ (iterate)
```

---

## Command Reference

### `/ddd` Commands

| Command | Description |
|---------|-------------|
| `/ddd start [name]` | Start new DDD flow |
| `/ddd resume [name]` | Resume existing DDD flow |
| `/ddd fork [old] [new]` | Fork flow for context recovery |
| `/ddd status` | Show all DDD flows |
| `/ddd help` | Show help |

### `/tdd` Commands

| Command | Description |
|---------|-------------|
| `/tdd start [name]` | Start new TDD flow |
| `/tdd resume [name]` | Resume existing TDD flow |
| `/tdd fork [old] [new]` | Fork flow for context recovery |
| `/tdd status` | Show all TDD flows |
| `/tdd help` | Show help |

### `/vdd` Commands

| Command | Description |
|---------|-------------|
| `/vdd start [name]` | Start new VDD flow |
| `/vdd resume [name]` | Resume existing VDD flow |
| `/vdd fork [old] [new]` | Fork flow for context recovery |
| `/vdd status` | Show all VDD flows |
| `/vdd help` | Show help |

---

## Feature Documentation Index

### ConfigService (ddd-config-service)

**What**: Centralized `.env` configuration system

**Files**:
- [Requirements](./ddd-config-service/01-requirements.md)
- [Specifications](./ddd-config-service/02-specifications.md)
- [Plan](./ddd-config-service/03-plan.md)
- [Implementation](./ddd-config-service/04-implementation-log.md)
- [Client Docs](./ddd-config-service/README.md)

**Status**: ✅ Complete

---

### Onboarding System (ddd-onboarding)

**What**: Telegram bot integration for subscription retrieval

**Files**:
- [Requirements](./ddd-onboarding/01-requirements.md)
- [Specifications](./ddd-onboarding/02-specifications.md)
- [Plan](./ddd-onboarding/03-plan.md)
- [Implementation](./ddd-onboarding/04-implementation-log.md)
- [Client Docs](./ddd-onboarding/README.md)

**Status**: ✅ Complete

---

### ConfigService Tests (tdd-config-service)

**What**: Unit tests for ConfigService

**Files**:
- [Requirements](./tdd-config-service/01-requirements.md)
- [Test Cases](./tdd-config-service/02-tests.md)
- [Status](./tdd-config-service/_status.md)

**Status**: 🟡 Tests Defined (Implementation Pending)

---

### Main UI Screens (vdd-main-ui)

**What**: ASCII mockups for all main screens

**Files**:
- [Requirements](./vdd-main-ui/01-requirements.md)
- [Visual Mockups](./vdd-main-ui/02-visual.md)
- [Status](./vdd-main-ui/_status.md)

**Status**: 🟡 Visual Defined (Implementation Pending)

---

## Best Practices

### Starting New Features

1. **Choose the right flow**:
   - New feature → Start with `/ddd start`
   - UI change → Start with `/vdd start`
   - Test coverage → Start with `/tdd start`
   - Technical spec → Start with `/sdd start`

2. **Complete all phases**: Don't skip phases
3. **Update status**: Keep `_status.md` current
4. **Get approval**: Explicit approval before phase transitions

### Resuming Work

1. **Read status first**: Check `_status.md` for current phase
2. **Review context**: Read all artifacts in flow directory
3. **Update status**: Note what you're working on
4. **Complete handoff**: Update status before ending session

### Documentation Quality

- **Requirements**: Clear problem statement, user stories, acceptance criteria
- **Specifications**: Architecture diagrams, data models, interfaces
- **Plan**: Atomic tasks, file changes, dependencies
- **Implementation**: Progress log, deviations, learnings
- **README**: Client-facing, simple language, examples

---

## Troubleshooting

### Lost Context

**Problem**: Session ended mid-flow, context lost

**Solution**:
```bash
# Fork the existing flow
/ddd fork existing-name new-name

# Review _status.md to understand state
# Continue from current phase
```

### Unclear Next Steps

**Problem**: Not sure what to do next

**Solution**:
1. Read `_status.md` for current phase
2. Read last artifact modified
3. Check "Next Steps" in status file
4. Ask for clarification

### Multiple Active Flows

**Problem**: Too many parallel flows

**Solution**:
```bash
# Check all active flows
/ddd status
/tdd status
/vdd status

# Focus on one flow at a time
# Complete or pause others
```

---

## Integration with Project Structure

```
VPNclient-app/
├── flows/                    # Development flows
│   ├── ddd-*/               # Feature documentation
│   ├── tdd-*/               # Test documentation
│   ├── vdd-*/               # Visual documentation
│   └── .templates/          # Templates
├── lib/                     # Source code
│   ├── services/            # Services (ConfigService, etc.)
│   ├── pages/               # UI screens
│   └── ...
├── test/                    # Tests
│   └── services/            # Service tests
└── docs/                    # General documentation
```

**Mapping**:
- `flows/ddd-config-service/` → `lib/services/config_service.dart`
- `flows/ddd-onboarding/` → `lib/services/onboarding_service.dart`
- `flows/tdd-config-service/` → `test/services/config_service_test.dart` (pending)
- `flows/vdd-main-ui/` → `lib/pages/*/` (verification pending)

---

## Next Steps

### Immediate

1. ✅ Complete DDD flows for existing features
2. 🟡 Implement TDD tests for ConfigService
3. 🟡 Verify VDD mockups match implementation
4. ⏳ Create DDD flow for VpnService

### Recommended

1. Add unit tests for OnboardingService
2. Add integration tests for deep link flow
3. Create VDD flow for Settings page
4. Create TDD flow for VpnService

---

## Resources

- [DDD Flow Reference](./ddd.md)
- [TDD Flow Reference](./tdd.md)
- [VDD Flow Reference](./vdd.md)
- [SDD Flow Reference](./sdd.md)
- [ENV Configuration](../ENV_CONFIGURATION.md)
- [Integration Summary](../INTEGRATION_SUMMARY.md)

---

**Version**: 1.0  
**Last Updated**: 2026-03-01  
**Maintained By**: VPNclient Team
