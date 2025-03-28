# Shell Script Reorganization Specification

This document outlines the plan for reorganizing shell scripts in the repository to improve maintainability, clarity, and organization. It builds upon the principles defined in the [Scripts README](../scripts/README.md#shell-script-organization).

## Table of Contents

- [Shell Script Reorganization Specification](#shell-script-reorganization-specification)
  - [Table of Contents](#table-of-contents)
  - [Background](#background)
  - [Goals](#goals)
  - [Current State](#current-state)
  - [Target State](#target-state)
  - [Implementation Plan](#implementation-plan)
    - [Phase 1: Analysis and Inventory](#phase-1-analysis-and-inventory)
    - [Phase 2: Setup Common Utilities](#phase-2-setup-common-utilities)
    - [Phase 3: Reorganize Module-Specific Scripts](#phase-3-reorganize-module-specific-scripts)
    - [Phase 4: Reorganize Standalone Scripts](#phase-4-reorganize-standalone-scripts)
    - [Phase 5: Validate and Update Documentation](#phase-5-validate-and-update-documentation)
  - [Script Migration Mapping](#script-migration-mapping)
  - [Validation Checklist](#validation-checklist)
  - [Compatibility Considerations](#compatibility-considerations)
  - [References](#references)

## Background

The repository currently contains a mix of PowerShell and shell scripts with inconsistent organization. Shell scripts serve various purposes, some being used by PowerShell modules while others function independently. According to the organizational principles defined in the [Scripts README](../scripts/README.md#organization-principles), scripts should be organized based on their function and usage patterns rather than simply by language.

## Goals

1. Improve script discoverability and maintainability
2. Clarify relationships between scripts and the components that use them
3. Reduce confusion about which scripts to use in different scenarios
4. Establish clear conventions for future script additions
5. Ensure cross-platform compatibility where needed

## Current State

The shell scripts are currently in various locations, primarily in the root of the `scripts/` directory:

- `scripts/store-acr-credentials.sh`
- `scripts/setup-acr-auth.sh`
- `scripts/create-acr-service-principal.sh`
- `scripts/docker-login-acr.sh`
- `scripts/Modules/Common/bash-utils.sh`

This flat structure doesn't clearly indicate:

- Which scripts are used by which PowerShell modules
- The dependencies between shell scripts
- The functional domains each script belongs to

## Target State

The target organization will follow these patterns:

1. **Module-Specific Shell Scripts**: Located in `ShellScripts` subdirectories within relevant PowerShell modules
2. **Common Utility Scripts**: Located in `Modules/Common/`
3. **Standalone Functional Scripts**: Organized by domain in dedicated directories

For example:

```plaintext
scripts/
├── Modules/
│   ├── Docker/
│   │   ├── Docker.psm1
│   │   ├── Docker.psd1
│   │   └── ShellScripts/
│   │       └── docker-login-acr.sh
│   └── Common/
│       └── bash-utils.sh
└── ACR/
    ├── create-acr-service-principal.sh
    ├── setup-acr-auth.sh
    └── store-acr-credentials.sh
```

## Implementation Plan

### Phase 1: Analysis and Inventory

1. Inventory all shell scripts and their purposes
2. Document dependencies between scripts
3. Identify which PowerShell modules invoke which shell scripts
4. Create mapping of current to future locations

### Phase 2: Setup Common Utilities

1. Ensure `Modules/Common` directory is properly configured
2. Confirm `bash-utils.sh` is correctly placed
3. Update any references to this utility

### Phase 3: Reorganize Module-Specific Scripts

1. Identify shell scripts used by specific PowerShell modules
2. For each module-specific script:
   - Create `ShellScripts` subdirectory in the module
   - Move script to the subdirectory
   - Update references in PowerShell code

### Phase 4: Reorganize Standalone Scripts

1. Create functional domain directories (e.g., `ACR/`)
2. Move relevant standalone scripts
3. Update documentation and cross-references

### Phase 5: Validate and Update Documentation

1. Test all scripts in their new locations
2. Update README.md with accurate directory structure
3. Update any other documentation references

## Script Migration Mapping

| Current Location                          | Target Location                                           | Rationale             |
| ----------------------------------------- | --------------------------------------------------------- | --------------------- |
| `scripts/docker-login-acr.sh`             | `scripts/Modules/Docker/ShellScripts/docker-login-acr.sh` | Used by Docker module |
| `scripts/create-acr-service-principal.sh` | `scripts/ACR/create-acr-service-principal.sh`             | ACR-specific function |
| `scripts/setup-acr-auth.sh`               | `scripts/ACR/setup-acr-auth.sh`                           | ACR-specific function |
| `scripts/store-acr-credentials.sh`        | `scripts/ACR/store-acr-credentials.sh`                    | ACR-specific function |
| `scripts/Modules/Common/bash-utils.sh`    | No change (already in correct location)                   | Common utility        |

## Validation Checklist

- [ ] All scripts are executable in their new locations
- [ ] All PowerShell scripts correctly reference shell scripts
- [ ] All script dependencies are resolved
- [ ] Documentation is updated with new locations
- [ ] No regression in functionality

## Compatibility Considerations

1. **CI/CD Pipelines**: Update any CI/CD configurations that reference shell scripts
2. **Documentation**: Update any external documentation that references shell scripts
3. **Cross-Platform**: Ensure scripts work correctly on Windows, macOS, and Linux

## References

- [Scripts README - Shell Script Organization](../scripts/README.md#shell-script-organization)
- [Scripts README - Organization Principles](../scripts/README.md#organization-principles)
- [Scripts README - Script Placement Guidelines](../scripts/README.md#script-placement-guidelines)
