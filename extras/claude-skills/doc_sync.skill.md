---
name: doc_sync
version: 1.0.0
type: documentation
description: Ensure documentation matches actual code behavior
scope:
  - documentation
  - readme
  - api_docs
allowed_paths:
  - README.md
  - docs/**
  - "*.md"
forbidden_paths:
  - "**/*.ts"
  - "**/*.py"
  - "**/*.vue"
requires:
  - tests_pass
commit_style: "docs(sync): "
confidence_threshold: 0.7
---

## Intent

Ensure all documentation accurately reflects the current state of the codebase.
Documentation drift is a silent killer of developer productivity.

## Allowed Actions

- Update API endpoint examples to match actual routes
- Sync README installation steps with actual dependencies
- Remove references to deleted features
- Update configuration examples
- Fix broken internal doc links
- Add missing documentation for new public APIs
- Update changelog entries

## Forbidden Actions

- Modify any source code
- Change actual API behavior to match docs
- Remove documentation without verification
- Add speculative feature documentation

## Validation Criteria

- All code examples in docs are syntactically valid
- All referenced files/paths exist
- API examples match actual endpoint signatures
- Installation steps are executable

## Sync Targets

1. **README.md**: Installation, quick start, basic usage
2. **docs/api.md**: Endpoint documentation
3. **docs/architecture.md**: System design (if exists)
4. **CHANGELOG.md**: Version history

## Execution Pattern

1. Parse all markdown files
2. Extract code blocks and verify syntax
3. Cross-reference with actual codebase
4. Identify drift (outdated examples, missing docs)
5. Apply minimal corrections
6. Verify links resolve
7. Commit with proper message format
