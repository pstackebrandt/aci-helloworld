# Scripts Directory

This directory contains PowerShell scripts for managing the Azure Container Registry setup and operations.

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

## Best Practices

1. Always use the appropriate module for line ending management
2. Keep sensitive information in environment files
3. Use the -DryRun parameter when available to preview changes
4. Follow the script organization structure for new Scripts
5. Run Validate-Config.ps1 before making changes to ensure configuration is valid
