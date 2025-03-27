# Git and Changelog Tools Modularization Specification

This document outlines the approach for modularizing and optimizing the changelog management, Git staging tools, and commit message generation for better reusability across projects.

## Table of Contents

- [Git and Changelog Tools Modularization Specification](#git-and-changelog-tools-modularization-specification)
  - [Table of Contents](#table-of-contents)
  - [Git Module Specification](#git-module-specification)
    - [Git Module Purpose](#git-module-purpose)
    - [Git Module Structure](#git-module-structure)
    - [Git Core Functions](#git-core-functions)
      - [Get-GitStagedFiles](#get-gitstagedfiles)
      - [Format-GitStagedOutput](#format-gitstagedoutput)
      - [Get-GitFileDiff](#get-gitfilediff)
      - [New-GitCommitMessage](#new-gitcommitmessage)
    - [Git Additional Functions](#git-additional-functions)
  - [Changelog Module Specification](#changelog-module-specification)
    - [Changelog Module Purpose](#changelog-module-purpose)
    - [Changelog Module Structure](#changelog-module-structure)
    - [Changelog Core Functions](#changelog-core-functions)
      - [Get-ChangelogSection](#get-changelogsection)
      - [Update-ChangelogSection](#update-changelogsection)
      - [New-ChangelogEntry](#new-changelogentry)
      - [Test-ChangelogFormat](#test-changelogformat)
    - [Changelog Additional Functions](#changelog-additional-functions)
  - [Commit Message Generation](#commit-message-generation)
    - [Purpose](#purpose)
    - [Implementation Approaches](#implementation-approaches)
      - [Git History-Based Approach](#git-history-based-approach)
      - [IDE Integration](#ide-integration)
    - [Core Features](#core-features)
      - [Automatic Change Classification](#automatic-change-classification)
      - [Message Styles](#message-styles)
      - [Workflow Integration](#workflow-integration)
  - [Cross-Project Reusability](#cross-project-reusability)
    - [Installation and Setup](#installation-and-setup)
    - [Configuration](#configuration)
    - [Compatibility](#compatibility)
  - [Integration Strategy](#integration-strategy)
    - [Version Management Integration](#version-management-integration)
    - [CI/CD Integration](#cicd-integration)
    - [Project-Specific Integration](#project-specific-integration)
  - [Implementation Checklist](#implementation-checklist)
    - [Phase 1: Module Framework](#phase-1-module-framework)
    - [Phase 2: Function Implementation](#phase-2-function-implementation)
    - [Phase 3: Integration](#phase-3-integration)
    - [Phase 4: Distribution and Documentation](#phase-4-distribution-and-documentation)
  - [Usage Examples](#usage-examples)
    - [Basic Git Usage](#basic-git-usage)
    - [Integrated Workflow Usage](#integrated-workflow-usage)
    - [Changelog Integration](#changelog-integration)
    - [Advanced Usage](#advanced-usage)
  - [Notes on Implementation](#notes-on-implementation)

## Git Module Specification

### Git Module Purpose

Create a dedicated PowerShell module for Git operations, particularly focused on obtaining and processing staged changes for changelog updates and commit message generation.

### Git Module Structure

```plaintext
scripts/Modules/Git/
  ├── Git.psd1                # Module manifest
  ├── Git.psm1                # Module implementation
  ├── Functions/              # Individual function files
  │   ├── Get-GitStagedFiles.ps1
  │   ├── Format-GitStagedOutput.ps1
  │   ├── Get-GitFileDiff.ps1
  │   ├── New-GitCommitMessage.ps1
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

#### New-GitCommitMessage

- [ ] Generate conventional commit messages from staged changes
- [ ] Analyze file types and change patterns for automatic categorization
- [ ] Support different message styles (conventional, simple, detailed)
- [ ] Integration with IDE tools and clipboard

### Git Additional Functions

- [ ] Test-GitRepository - Check if current directory is a Git repository
- [ ] Get-GitFileStatus - Get status of specific files
- [ ] Get-GitRepositoryInfo - Get basic information about the repository
- [ ] Analyze-GitChanges - Deeper analysis of changed content for commit messages

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

## Commit Message Generation

### Purpose

Provide tools to generate high-quality, consistent commit messages based on Git staged changes, reducing manual effort and improving commit history readability.

### Implementation Approaches

#### Git History-Based Approach

- [ ] Extract information solely from recent and staged Git changes
- [ ] No dependency on changelog entries or version updates
- [ ] Analyze diffs to understand context and content of changes
- [ ] Categorize changes automatically based on file types and patterns

#### IDE Integration

- [ ] Terminal command integration with Cursor
- [ ] Support for clipboard operations
- [ ] Optional GUI overlay for commit message preview
- [ ] Customizable templates and presets

### Core Features

#### Automatic Change Classification

- [ ] Detect version updates vs. regular changes
- [ ] Identify feature additions, fixes, documentation updates, etc.
- [ ] Apply appropriate conventional commit prefixes (feat, fix, docs)
- [ ] Suggest scope based on affected files and directories

#### Message Styles

- [ ] Conventional Commits format
- [ ] Simple concise format
- [ ] Detailed format with body and footer
- [ ] Project-specific custom formats

#### Workflow Integration

- [ ] Standalone operation from terminal
- [ ] Pre-commit hook integration
- [ ] Two-phase approach for version updates vs. regular commits

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
- [ ] IDE integration testing (VS Code, Cursor, etc.)

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
- [ ] Project-specific commit message templates

## Implementation Checklist

### Phase 1: Module Framework

- [ ] Create module directory structure
- [ ] Set up module manifests
- [ ] Implement core Git functions
- [ ] Implement core Changelog functions
- [ ] Write initial tests

### Phase 2: Function Implementation

- [ ] Extract and refactor existing functionality
- [ ] Implement new functions including commit message generation
- [ ] Complete test coverage
- [ ] Document functions with help

### Phase 3: Integration

- [ ] Create integration examples
- [ ] Update existing scripts to use modules
- [ ] Create configuration system
- [ ] Test cross-project compatibility
- [ ] Implement IDE integration for Cursor

### Phase 4: Distribution and Documentation

- [ ] Complete README files
- [ ] Create example projects
- [ ] Prepare for PowerShell Gallery
- [ ] Create user documentation

## Usage Examples

### Basic Git Usage

```powershell
# Import modules
Import-Module Git

# Generate commit message from staged changes
$commitMessage = New-GitCommitMessage

# Display suggested commit message
Write-Output $commitMessage

# Copy to clipboard for use in Cursor
$commitMessage | Set-Clipboard
```

### Integrated Workflow Usage

```powershell
# Stage changes
git add .

# Generate commit message
$message = New-GitCommitMessage -Style Conventional

# Review and edit if needed
$message = $message -replace "feat", "fix"

# Commit with generated message
git commit -m $message
```

### Changelog Integration

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

# Generate commit message that includes changelog update
$message = New-GitCommitMessage -IncludeChangelogReference
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
Update-ChangelogSection -Path $config.ChangelogPath -Section "Unreleased" -Category "Changed" -Entries $entries -DryRun

# Generate a detailed commit message
New-GitCommitMessage -Style Detailed -Scope "changelog" -IncludeBody
```

## Notes on Implementation

- Keep functions focused and single-purpose
- Follow PowerShell best practices
- Maintain backward compatibility where possible
- Use proper error handling and logging
- Include detailed help content in all functions
- Use standardized parameter names across functions
- Prioritize IDE integration for common workflows
