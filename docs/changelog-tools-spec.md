# Changelog Tools Modularization Specification

This document outlines the approach for modularizing and optimizing the changelog management and Git staging tools for better reusability across projects.

## Table of Contents

- [Git Module Specification](#git-module-specification)
- [Changelog Module Specification](#changelog-module-specification)
- [Cross-Project Reusability](#cross-project-reusability)
- [Integration Strategy](#integration-strategy)
- [Implementation Checklist](#implementation-checklist)

## Git Module Specification

### Git Module Purpose

Create a dedicated PowerShell module for Git operations, particularly focused on obtaining and processing staged changes for changelog updates.

### Git Module Structure

```plaintext
scripts/Modules/Git/
  ├── Git.psd1                # Module manifest
  ├── Git.psm1                # Module implementation
  ├── Functions/              # Individual function files
  │   ├── Get-GitStagedFiles.ps1
  │   ├── Format-GitStagedOutput.ps1
  │   ├── Get-GitFileDiff.ps1
  │   └── ...
  ├── Tests/                  # Test files
  │   ├── Git.Tests.ps1
  │   └── ...
  └── README.md               # Module documentation
```

### Git Core Functions

#### Get-GitStagedFiles

- [ ] Extract core functionality from existing `Get-StagedChanges.ps1`
- [ ] Implement parameters for filtering by file type/path
- [ ] Support for customizable status mapping
- [ ] Return structured object with full metadata

#### Format-GitStagedOutput

- [ ] Support multiple output formats (Text, JSON, CSV, Object)
- [ ] Customizable formatting options
- [ ] Support for colorization in console output

#### Get-GitFileDiff

- [ ] Retrieve diff content for specified files
- [ ] Options for context lines, format, etc.
- [ ] Support for unified or side-by-side diff

### Git Additional Functions

- [ ] Test-GitRepository - Check if current directory is a Git repository
- [ ] Get-GitFileStatus - Get status of specific files
- [ ] Get-GitRepositoryInfo - Get basic information about the repository

## Changelog Module Specification

### Changelog Module Purpose

Create a dedicated module for changelog operations that follows the Keep a Changelog format while providing flexibility for customization.

### Changelog Module Structure

```plaintext
scripts/Modules/Changelog/
  ├── Changelog.psd1           # Module manifest
  ├── Changelog.psm1           # Module implementation
  ├── Functions/               # Individual function files
  │   ├── Get-ChangelogSection.ps1
  │   ├── Update-ChangelogSection.ps1
  │   ├── New-ChangelogEntry.ps1
  │   ├── Test-ChangelogFormat.ps1
  │   └── ...
  ├── Templates/               # Entry templates
  │   ├── Default.xml
  │   └── ...
  ├── Tests/                   # Test files
  │   ├── Changelog.Tests.ps1
  │   └── ...
  └── README.md                # Module documentation
```

### Changelog Core Functions

#### Get-ChangelogSection

- [ ] Extract sections by name (Unreleased, specific version, etc.)
- [ ] Parse entries within sections
- [ ] Return structured data for manipulation

#### Update-ChangelogSection

- [ ] Add entries to specific sections
- [ ] Preserve existing content
- [ ] Optional validation
- [ ] Support for dry run mode

#### New-ChangelogEntry

- [ ] Generate entries from file changes, commit messages, or manual input
- [ ] Use templates for consistency
- [ ] Categorize automatically where possible (Added/Changed/Fixed)

#### Test-ChangelogFormat

- [ ] Validate adherence to Keep a Changelog format
- [ ] Check for missing headers, formatting issues, etc.
- [ ] Integration with markdownlint rules

### Changelog Additional Functions

- [ ] Merge-ChangelogSections - Move entries from one section to another
- [ ] New-ChangelogRelease - Create a new release from Unreleased section
- [ ] Export-ChangelogSection - Export sections to different formats

## Cross-Project Reusability

### Installation and Setup

- [ ] Create a module installer script
- [ ] Add PowerShell Gallery publishing support
- [ ] Documentation for installation methods

### Configuration

- [ ] External configuration file support
- [ ] Project-specific customization options
- [ ] Default settings with override capability

### Compatibility

- [ ] Cross-platform support (Windows, macOS, Linux)
- [ ] PowerShell version compatibility testing
- [ ] Git version compatibility testing

## Integration Strategy

### Version Management Integration

- [ ] Clear interfaces between changelog and version management
- [ ] Event-based communication between modules
- [ ] Shared configuration options

### CI/CD Integration

- [ ] Examples for GitHub Actions, Azure DevOps, etc.
- [ ] Support for automated changelog updates
- [ ] Validation steps for PR workflows

### Project-Specific Integration

- [ ] Customization hooks
- [ ] Project type detection
- [ ] Language-specific changelog entry generation

## Implementation Checklist

### Phase 1: Module Framework

- [ ] Create module directory structure
- [ ] Set up module manifests
- [ ] Implement core Git functions
- [ ] Implement core Changelog functions
- [ ] Write initial tests

### Phase 2: Function Implementation

- [ ] Extract and refactor existing functionality
- [ ] Implement new functions
- [ ] Complete test coverage
- [ ] Document functions with help

### Phase 3: Integration

- [ ] Create integration examples
- [ ] Update existing scripts to use modules
- [ ] Create configuration system
- [ ] Test cross-project compatibility

### Phase 4: Distribution and Documentation

- [ ] Complete README files
- [ ] Create example projects
- [ ] Prepare for PowerShell Gallery
- [ ] Create user documentation

## Usage Examples

### Basic Usage

```powershell
# Import modules
Import-Module Git
Import-Module Changelog

# Get staged changes
$stagedFiles = Get-GitStagedFiles

# Generate changelog entries from staged files
$entries = $stagedFiles | New-ChangelogEntry -Category "Changed"

# Update the changelog
Update-ChangelogSection -Section "Unreleased" -Category "Changed" -Entries $entries
```

### Advanced Usage

```powershell
# Custom configuration
$config = Get-Content -Path ".changelog.json" | ConvertFrom-Json

# Get staged changes with filtering
$stagedFiles = Get-GitStagedFiles -Include "*.ps1", "*.md" -ExcludePattern ".*\.tests\.ps1$"

# Generate entries with custom template
$entries = $stagedFiles | New-ChangelogEntry -TemplatePath "templates/custom.xml"

# Update with dry run to preview changes
Update-ChangelogSection -Path $config.ChangelogPath -Section "Unreleased" -Entries $entries -DryRun
```

## Notes on Implementation

- Keep functions focused and single-purpose
- Follow PowerShell best practices
- Maintain backward compatibility where possible
- Use proper error handling and logging
- Include detailed help content in all functions
- Use standardized parameter names across functions
