# Scripts Directory

This directory contains PowerShell scripts and Bash/Shell scripts for managing the Azure Container Registry setup and operations.

## Table of Contents

- [Scripts Directory](#scripts-directory)
  - [Table of Contents](#table-of-contents)
  - [Directory Structure](#directory-structure)
  - [Script Categories](#script-categories)
    - [Modules](#modules)
    - [Tools](#tools)
    - [Setup](#setup)
    - [Operations](#operations)
  - [Usage](#usage)
  - [Shell Script Organization](#shell-script-organization)
    - [Organization Principles](#organization-principles)
    - [Script Placement Guidelines](#script-placement-guidelines)
  - [Best Practices](#best-practices)

## Directory Structure

```text
scripts/
├── Modules/                    # PowerShell modules
│   ├── LineEndings/           # Line ending management
│   │   ├── LineEndings.psm1   # Core functions
│   │   ├── FileTypes.psd1     # Configuration
│   │   └── LineEndings.psd1   # Module manifest
│   ├── FileSystem/            # File system operations
│   │   ├── FileSystem.psm1    # Core functions
│   │   ├── GitIgnore.psm1     # GitIgnore management
│   │   └── FileSystem.psd1    # Module manifest
│   ├── Configuration/         # Configuration validation
│   │   ├── Configuration.psm1 # Core functions
│   │   └── Configuration.psd1 # Module manifest
│   ├── Common/                # Common utilities
│   │   └── bash-utils.sh      # Bash utility functions
│   └── System/                # System operations
│       └── BashExecution.psm1 # Bash script execution
├── Tools/                      # Utility scripts
│   ├── Test-LineEndings.ps1   # Line ending checker
│   └── Validate-Config.ps1    # Configuration validator
├── Setup/                      # Setup scripts
│   ├── Create-AzAcrServicePrincipal.ps1
│   └── Run-AcrSetup.ps1
└── Operations/                 # Operational scripts
    └── Run-DockerLogin.ps1    # Docker login to ACR
```

## Script Categories

### Modules

- **LineEndings**: Manages line endings across different file types
- **FileSystem**: Handles file system operations and GitIgnore management
- **Configuration**: Validates configuration files and environment variables
- **System**: Provides system-level operations like bash script execution
- **Common**: Common utilities for both PowerShell and Bash scripts

### Tools

- **Test-LineEndings**: Checks and fixes line endings in files
- **Validate-Config**: Validates configuration files and environment setup

### Setup

- **Create-AzAcrServicePrincipal**: Creates Azure service principal for ACR
- **Run-AcrSetup**: Sets up ACR authentication

### Operations

- **Run-DockerLogin**: Handles Docker login to ACR

## Usage

1. **Line Ending Management**:

   ```powershell
   # Check line endings
   .\Tools\Test-LineEndings.ps1
   
   # Fix line endings
   .\Tools\Test-LineEndings.ps1 -Fix
   
   # Preview changes
   .\Tools\Test-LineEndings.ps1 -Fix -DryRun
   ```

2. **Configuration Validation**:

   ```powershell
   # Validate all configuration files
   .\Tools\Validate-Config.ps1
   ```

3. **ACR Setup**:

   ```powershell
   # Create service principal
   .\Setup\Create-AzAcrServicePrincipal.ps1
   
   # Run ACR setup
   .\Setup\Run-AcrSetup.ps1
   ```

4. **Docker Operations**:

   ```powershell
   # Login to ACR
   .\Operations\Run-DockerLogin.ps1
   ```

## Shell Script Organization

This section outlines the principles and guidelines for organizing shell scripts within the repository.

### Organization Principles

1. **Cohesion Over Language**: Group scripts by function, not by language
2. **Locality of Reference**: Keep scripts close to where they're used
3. **Clear Dependencies**: Make script dependencies obvious
4. **Functional Domains**: Organize standalone scripts by their domain

### Script Placement Guidelines

1. **Module-Specific Shell Scripts**:
   - Place in a `ShellScripts` subfolder within the PowerShell module that uses them
   - Example: If a shell script is only used by the Docker module, place it in `Modules/Docker/ShellScripts/`

2. **Common Utility Shell Scripts**:
   - Place in `Modules/Common/` if used by multiple scripts
   - Example: `bash-utils.sh` for common bash functions

3. **Standalone Functional Scripts**:
   - Organize by functional domain in dedicated folders
   - Example: ACR-related scripts in `Setup/ShellScripts/` or `ACR/`

## Best Practices

1. Always use the appropriate module for line ending management
2. Keep sensitive information in environment files
3. Use the -DryRun parameter when available to preview changes
4. Follow the script organization structure for new scripts
5. Run Validate-Config.ps1 before making changes to ensure configuration is valid
6. For shell scripts invoked from PowerShell, use the `System/BashExecution.psm1` module
7. Maintain consistent line endings: LF for shell scripts, CRLF for PowerShell
8. Document shell script dependencies clearly in comments
9. When creating a new shell script, consider which script language should be used.
10. For cross-platform scenarios, prefer shell scripts in CI/CD and GitHub Actions
