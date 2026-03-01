# Claude ADR System Guide

**A comprehensive Architectural Decision Record system designed for AI-assisted development workflows**

## Overview

This ADR (Architectural Decision Record) system is specifically designed for projects where AI assistants (like Claude) work alongside human developers. It provides structured decision tracking, context preservation, and branching strategy integration that scales from small chores to major architectural changes.

## Key Principles

### 1. **Every Branch Gets Documentation**
- No decision is too small to document
- Small changes can have significant future impact
- Complete decision history prevents context loss

### 2. **AI-Friendly Structure**
- Structured metadata for quick parsing
- Cross-references enable relationship discovery
- TOML index provides fast lookup and filtering

### 3. **Branching Strategy Integration**
- ADRs organized by branch type (feat/, chore/, docs/, fix/)
- Natural progression from development workflow to documentation
- Merged branches archived with full context preserved

### 4. **Context Preservation**
- Complete decision rationale captured
- Alternative options and trade-offs documented
- Implementation details and lessons learned preserved

## Directory Structure

```
.claude/
├── adr-index.toml              # Master index with metadata and cross-references
├── adr-helper.sh               # Scripts for ADR management
├── ADR-SYSTEM-GUIDE.md         # This guide (portable across projects)
├── branches/                   # Active branch ADRs
│   ├── feat/
│   │   ├── feature-name.md
│   │   └── another-feature.md
│   ├── chore/
│   │   └── cleanup-task.md
│   ├── docs/
│   │   └── documentation-work.md
│   └── fix/
│       └── bugfix-name.md
├── merged/                     # Archived merged branch ADRs
│   ├── 2024-12/
│   ├── 2025-01/
│   └── [year-month]/
└── templates/                  # ADR templates for consistency
    ├── branch-adr-template.md
    ├── feature-template.md
    ├── chore-template.md
    └── research-template.md
```

## Core Components

### 1. ADR Index (adr-index.toml)

The TOML index serves as the system's brain, providing:

- **Fast Lookup**: Quick access to any ADR by branch name
- **Cross-References**: Related decisions and dependencies
- **Categorization**: Group decisions by domain (performance, testing, etc.)
- **Metadata**: Created dates, authors, PR numbers, merge status
- **Tag System**: Flexible filtering and search capabilities

```toml
[active.feat]
"tower-redis-client" = {
    file = "feat/tower-redis-client.md",
    created = "2025-01-17",
    author = "Claude",
    tags = ["tower", "redis", "client", "middleware"],
    pr = 15,
    description = "Tower-based Redis client with middleware"
}
```

### 2. Branch ADRs

Each branch gets a comprehensive ADR following a standardized structure:

**Meta Section**: Branch name, type, status, PR links
**Problem Statement**: Context, goals, and non-goals
**Decision Record**: Options considered, chosen solution, rationale
**Implementation**: Key changes, testing strategy, migration plan
**Investigation**: Research findings, experiments, dead ends
**Challenges & Solutions**: Technical and process challenges
**Impact Assessment**: Performance, user, maintenance, security impact
**Quality Assurance**: Code review notes, testing results
**Outcome & Lessons**: Results, performance data, lessons learned

### 3. Cross-Reference System

The index maintains relationships between decisions:

```toml
[relationships.depends_on]
"feat/tower-redis-client" = ["feat/large-payload-testing", "feat/property-based-testing"]

[relationships.enables]
"feat/large-payload-testing" = ["feat/tower-redis-client", "performance-optimizations"]

[categories.performance]
branches = ["feat/large-payload-testing", "feat/tower-redis-client"]
```

## Workflow Integration

### Creating a New ADR

1. **Create Branch**: Follow standard git-flow naming conventions
2. **Generate ADR**: Use template to create branch ADR file
3. **Update Index**: Add entry to adr-index.toml with metadata
4. **Work & Document**: Update ADR as implementation progresses
5. **Final Review**: Complete ADR before merge
6. **Archive**: Move to merged/ directory post-merge

### During Development

- **Update Progress**: Keep ADR current with implementation
- **Document Decisions**: Add new insights, trade-offs, challenges
- **Link Related Work**: Update cross-references as relationships emerge
- **Capture Lessons**: Document what worked, what didn't, why

### At Merge Time

- **Final Update**: Complete all sections, add final outcomes
- **Update Index**: Mark as merged, add merge date
- **Archive**: Move ADR to appropriate merged/[year-month]/ directory
- **Update References**: Update any dependent ADRs

## AI Assistant Benefits

### For Claude/AI Assistants

1. **Structured Context**: Predictable format for parsing and understanding
2. **Decision History**: Complete rationale for past choices
3. **Relationship Mapping**: Understanding of dependencies and impacts
4. **Pattern Recognition**: Reusable decision patterns across projects
5. **Quality Guidance**: Standards and examples for future decisions

### For Human Developers

1. **Onboarding**: Complete context for new team members
2. **Decision Archaeology**: Understanding why choices were made
3. **Impact Analysis**: Seeing how decisions affect related work
4. **Learning Resource**: Examples of good decision-making processes
5. **Maintenance Guide**: Context for future modifications

## Scaling Considerations

### Small Projects (1-10 branches)
- Simple directory structure
- Basic cross-referencing
- Manual index maintenance acceptable

### Medium Projects (10-50 branches)
- Helper scripts become valuable
- Category system important for organization
- Regular cleanup of merged branches

### Large Projects (50+ branches)
- Automation becomes critical
- Advanced tagging and filtering needed
- Consider retention policies for old ADRs

## Implementation Tips

### Starting Simple
1. Begin with basic template and index structure
2. Focus on consistency over complexity
3. Establish routine of updating ADRs during development
4. Regular review and improvement of the system

### Growing the System
1. Add categories as patterns emerge
2. Develop helper scripts based on common tasks
3. Create project-specific templates for recurring work types
4. Consider integration with code review processes

### Avoiding Pitfalls
1. **Don't Over-Engineer**: Start simple, evolve as needed
2. **Maintain Currency**: Outdated ADRs are worse than no ADRs
3. **Focus on Value**: Document decisions that matter
4. **Keep Templates Updated**: Evolve format based on usage
5. **Prevent Duplicates**: Regular directory audits to catch file duplication
6. **Plan Migration**: Don't let legacy content accumulate without organization

## Template Structure

### Standard Branch ADR Template

```markdown
# Branch ADR: [branch-name]

## Meta
- **Branch**: [branch-name]
- **Type**: [feat|chore|docs|fix]
- **Created**: [date]
- **Status**: [Active|Merged|Abandoned]
- **Author**: [name]
- **PR**: [number or (not yet created)]

## Problem Statement
### Context
[Describe the situation requiring a decision]

### Goals
[What we're trying to achieve]

### Non-Goals
[What we're explicitly not doing]

## Decision Record
### Options Considered
[List alternatives with pros/cons]

### Decision
[Chosen solution and rationale]

### Trade-offs Accepted
[What we're giving up]

## Implementation
[Key changes, testing, migration plans]

## Investigation Notes
[Research, experiments, dead ends]

## Challenges & Solutions
[Technical and process challenges encountered]

## Impact Assessment
[Performance, user, maintenance, security impacts]

## Quality Assurance
[Testing results, review notes]

## Outcome & Lessons
[Final results and lessons learned]

## Tags
[space-separated tags for filtering]
```

## Cross-Project Portability

### Adapting to New Projects

1. **Copy Core Structure**: ADR-SYSTEM-GUIDE.md, templates/, adr-index.toml structure
2. **Customize Categories**: Adapt categories to project domains
3. **Adjust Templates**: Modify templates for project-specific needs
4. **Update Helper Scripts**: Adapt automation to local workflows

### Technology Agnostic

This system works across:
- **Languages**: Rust, Python, JavaScript, Go, etc.
- **Frameworks**: Web, mobile, systems, data science
- **Team Sizes**: Solo developers to large teams
- **Project Types**: Libraries, applications, infrastructure

### Integration Points

- **Git Workflows**: git-flow, GitHub Flow, GitLab Flow
- **Issue Tracking**: GitHub Issues, Jira, Linear
- **Code Review**: GitHub PR, GitLab MR, Azure DevOps
- **Documentation**: mdbook, GitBook, Confluence

## Success Metrics

### Adoption Indicators
- ADRs created for all significant branches
- Regular updates during development
- Reference to ADRs in code reviews
- Use of cross-references and categories

### Quality Indicators
- ADRs contain sufficient context for decision recreation
- Implementation matches documented decisions
- Lessons learned captured and referenced in future work
- Cross-references help navigate related decisions

### Value Indicators
- Faster onboarding of new team members
- Reduced re-litigation of past decisions
- Better impact analysis for proposed changes
- Improved consistency in decision-making processes

## Migration and Consolidation

### Common Legacy Content Patterns

When adopting this ADR system in existing projects, you'll likely encounter:

**Scattered Decision Documents**
- Design docs in various formats and locations
- Email threads with architectural decisions
- Wiki pages with outdated decision rationale
- Comments in code with design explanations

**Duplicate Content**
- Same information in multiple files/locations
- Different versions of the same document
- Legacy docs that should be archived

**Organizational Debt**
- Files in wrong locations
- Inconsistent naming conventions
- Mixed purposes in single documents
- Unclear file ownership and maintenance

### Migration Strategy

#### Phase 1: Assessment and Planning
```bash
# 1. Inventory existing documentation
find . -name "*.md" | grep -E "(design|decision|architecture|context)" > inventory.txt

# 2. Identify duplicates
find . -name "*.md" -exec basename {} \; | sort | uniq -d

# 3. Check for scattered content
grep -r "decision\|rationale\|chose\|alternative" --include="*.md" .
```

#### Phase 2: Content Triage
**Keep and Migrate**: Valuable decisions that should become ADRs
- Clear architectural choices with rationale
- Design decisions that affect multiple components
- Technology selection decisions
- Process decisions that set precedents

**Archive**: Historical content that shouldn't be lost but isn't active
- Old design docs that informed past decisions
- Superseded approaches and their lessons
- Completed project retrospectives

**Consolidate**: Duplicate or fragmented content
- Same information in multiple places
- Partial decisions across multiple documents
- Related decisions that should be linked

**Discard**: Content that no longer adds value
- Outdated technical specifications
- Superseded and irrelevant decisions
- Incomplete or abandoned design work

#### Phase 3: Systematic Migration

**Create Migration Tracking**
```toml
# migration-tracking.toml
[legacy_content]
"old-design-doc.md" = { 
    action = "migrate", 
    target_adr = "feat/new-architecture.md",
    completion = "pending"
}
"duplicate-context.md" = {
    action = "consolidate",
    keep_version = "docs/context/main-context.md",
    completion = "done"
}
```

**Execution Steps**
1. **Verify Before Removal**: Always diff duplicate files to ensure they're truly identical
2. **Preserve History**: Move rather than delete when content value is uncertain
3. **Update References**: Search codebase for links to moved/removed files
4. **Document Changes**: Update project documentation about new structure

### Real-World Consolidation Experience

Based on the resp-parser-rs consolidation, here are proven patterns:

#### Duplicate Detection and Resolution
```bash
# Proven approach for finding and handling duplicates
for file in $(find .claude -name "*.md" -not -path ".claude/branches/*"); do
    basename_file=$(basename "$file")
    # Check if same-named file exists in subdirectories
    find .claude -name "$basename_file" -not -path "$file" | while read duplicate; do
        echo "Potential duplicate: $file vs $duplicate"
        diff -q "$file" "$duplicate" || echo "  -> Files differ"
    done
done
```

#### Safe Migration Process
1. **Verification First**
   ```bash
   # Always verify files are identical before removing
   diff file1.md file2.md
   # Check for any references to the file being removed
   grep -r "file1.md" . --exclude-dir=.git
   ```

2. **Gradual Execution**
   - Remove clear duplicates first (lowest risk)
   - Handle legacy content migration second
   - Update references and documentation last

3. **Document Everything**
   - Create consolidation plan before starting
   - Track what was moved/removed and why
   - Update directory documentation to reflect changes

#### Lessons from Practice

**What Worked Well**
- **Systematic Approach**: Plan first, execute methodically
- **Verification Steps**: diff checks prevented data loss
- **Clear Categories**: Easy decisions (duplicates) vs complex ones (legacy content)
- **Documentation**: Comprehensive tracking of changes and rationale

**Common Pitfalls**
- **Rushing Removal**: Always verify before deleting
- **Missing References**: Search entire codebase for file references
- **Legacy Value Uncertainty**: When in doubt, archive rather than delete
- **Incomplete Migration**: Finish one category before starting another

**Best Practices Discovered**
- **Branch Alignment**: Consolidation work fits perfectly with "cleanup" branches
- **Immediate Benefits**: Directory clarity improves navigation significantly
- **System Maturity**: Clean structure signals production-ready system
- **Cross-Project Value**: Clean examples help adoption in other projects

### Consolidation Checklist

#### Pre-Migration
- [ ] Create complete inventory of existing documentation
- [ ] Identify and categorize all duplicates
- [ ] Plan migration approach and timeline
- [ ] Create tracking system for migration progress
- [ ] Set up backup/archive locations for uncertain content

#### During Migration
- [ ] Verify file contents before any removal
- [ ] Check for references to files being moved/removed
- [ ] Test that all links still work after changes
- [ ] Update directory documentation as you go
- [ ] Commit changes in logical groups for easy rollback

#### Post-Migration
- [ ] Verify no broken references remain
- [ ] Update project documentation about new structure
- [ ] Train team on new organization
- [ ] Establish processes to prevent future duplication
- [ ] Document lessons learned for future projects

## Future Enhancements

### Potential Automation
- **Auto-generation**: Create ADR templates from branch names
- **PR Integration**: Automatically link ADRs to pull requests
- **Status Tracking**: Sync ADR status with branch/PR status
- **Metrics Collection**: Track decision patterns and outcomes

### Advanced Features
- **Decision Trees**: Visual representation of option evaluations
- **Impact Graphs**: Visualization of decision relationships
- **Search Interface**: Advanced filtering and discovery
- **Template Evolution**: Machine learning for template improvement

## Language-Specific Adaptations

### Rust Projects

**Directory Structure Considerations**:
- Place `.claude/` at workspace root (for multi-crate projects)
- Consider separate ADRs for major crate decisions
- Document `Cargo.toml` feature flag decisions
- Track dependency upgrade rationales

**Common ADR Categories**:
- `performance` - Optimization decisions, benchmarking results
- `safety` - Memory safety, concurrency patterns
- `api-design` - Public API evolution, breaking changes
- `dependencies` - Crate selection, version pinning
- `testing` - Property testing, fuzzing strategies

**Rust-Specific Template Additions**:
```toml
[rust_specifics]
safety_analysis = "required/optional"
breaking_changes = "major/minor/patch"
benchmark_impact = "measured/estimated/none"
```

### Python Projects

**Directory Structure Considerations**:
- Compatible with `pyproject.toml` and `setup.py` structures
- Consider ADRs for virtual environment strategies
- Document packaging and distribution decisions

**Common ADR Categories**:
- `packaging` - Distribution, dependency management
- `typing` - Type hints adoption, mypy configuration
- `async` - asyncio patterns, concurrency approaches
- `testing` - pytest strategies, test organization

### JavaScript/TypeScript Projects

**Directory Structure Considerations**:
- Works with monorepos (nx, lerna, rush)
- Consider ADRs for build tool decisions
- Document framework migration paths

**Common ADR Categories**:
- `bundling` - Webpack, vite, rollup decisions
- `typing` - TypeScript adoption, configuration
- `state-management` - Redux, zustand, context patterns
- `testing` - Jest, vitest, cypress strategies

### Go Projects

**Directory Structure Considerations**:
- Align with Go module structure
- Consider ADRs for package organization
- Document interface design decisions

**Common ADR Categories**:
- `concurrency` - Goroutine patterns, channel usage
- `error-handling` - Error wrapping, custom errors
- `interfaces` - API design, abstraction levels
- `dependencies` - Module selection, vendor strategies

### General Guidelines for Any Language

1. **Build System Integration**: Document decisions about build tools, CI/CD
2. **Dependency Management**: Track rationale for major dependencies
3. **Code Organization**: Architectural patterns, module structure
4. **Testing Strategy**: Framework choices, coverage approaches
5. **Performance**: Benchmarking, optimization decisions

## Getting Started Checklist

### Initial Setup
- [ ] Create `.claude/` directory structure
- [ ] Copy `ADR-SYSTEM-GUIDE.md` to project
- [ ] Create `adr-index.toml` with project metadata
- [ ] Set up templates directory with basic templates
- [ ] Create first ADR for current branch/work

### First Month
- [ ] Create ADRs for 3-5 branches
- [ ] Establish categories relevant to project
- [ ] Add cross-references between related ADRs
- [ ] Review and refine templates based on usage
- [ ] Train team on ADR creation and maintenance

### Ongoing
- [ ] Regular ADR reviews and updates
- [ ] Archive merged branches monthly/quarterly
- [ ] Evolve categories and tags as project grows
- [ ] Share learnings and improvements with other projects
- [ ] Consider automation opportunities

---

## Example Projects Using This System

### resp-parser-rs (Rust Library)
**Scale**: Medium project with comprehensive ecosystem examples
**Migration Results**: 
- Reduced top-level files from 16 → 7 (-56% reduction)
- Eliminated 7 duplicate/misplaced files
- Improved navigation and maintenance significantly
**Key Lessons**: Systematic approach with verification steps prevents data loss
**Templates**: Available in project for reference

### [Your Project Here]
Add your experience and adaptations to help others learn from real-world usage

## Contributing to This Guide

This guide evolves based on real-world usage across different projects. Please contribute:

1. **Lessons Learned**: What worked, what didn't, why
2. **Adaptations**: How you modified the system for your project
3. **Automation**: Scripts and tools you developed
4. **Templates**: Project-specific templates that might help others
5. **Migration Experiences**: Consolidation approaches and results
6. **Scaling Insights**: How the system performs at different project sizes

---

*Created: 2025-01-17*
*Version: 1.1*

