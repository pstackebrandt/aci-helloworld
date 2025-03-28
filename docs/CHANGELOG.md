# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note on ordering:** Within each version section, entries are listed with newest changes at the top of each category for better visibility of recent changes.
>
> **Note on documentation linting:** Minor linting and formatting changes in documentation files are not listed in the changelog unless they significantly improve readability or correct factual errors.

## [Unreleased]

### Added

- Added shell-script-reorganization-spec.md defining the comprehensive plan for reorganizing shell scripts across modules and improving maintainability
- Added comprehensive Git and changelog tools modularization specification
- Added commit message generation design to tooling specification
- Added standardized changelog format following Keep a Changelog guidelines
- Added version comparison links for easy tracking of changes between releases
- Added Unreleased section to track upcoming changes
- Added PowerShell scripts for viewing staged Git changes and updating changelog
- Added modular structure for PowerShell and Bash scripts
- Added comprehensive test framework for Azure Service Principal modules
- Added Docker module with documentation and tests
- Added Line Endings module for consistent file formatting
- Added FileSystem and System utility modules
- Added automated tools for changelog maintenance and Git integration
- Added script documentation with standardized help format
- Added detailed modularization specification for changelog and Git tools
- Added implementation roadmap with structured checklists

### Changed

- Enhanced git-changelog-tools-spec.md with improved Git status handling, documentation change detection, and implementation learnings
- Enhanced Get-StagedChanges.ps1 with improved handling of renamed files and special Git status codes
- Improved Update-ChangelogFromStaged.ps1 with better documentation change detection and consistent newline handling
- Updated documentation for README
- Updated multiple PowerShell scripts (2 files)
- Improved development tooling documentation with detailed implementation plans
- Improved changelog structure for better readability and consistency
- Standardized section headings across all version entries
- Updated formatting to align with Markdown best practices
- Reorganized scripts into logical modules for better maintainability
- Improved test structure with dedicated test configuration
- Enhanced Docker operations with dedicated module
- Renamed scripts for better discoverability and consistency
- Enhanced credential storage scripts with improved security practices
- Refactored validation scripts for better performance and reliability
- Enhanced markdown documents to comply with markdownlint standards

### Fixed

- Fixed inconsistent section naming in older changelog entries
- Fixed missing version comparison links
- Fixed dates for clarity and future reference
- Updated version management scripts with improved functionality
- Improved credential storage scripts for better security
- Fixed configuration validation with better test coverage
- Fixed line ending issues in Bash credential scripts
- Fixed potential security issues in credential storage

## [1.0.3] - 2024-03-26

### Added in 1.0.3

- Added `.gitattributes` file to enforce consistent line endings across different file types
- Added line ending normalization for shell scripts (LF), PowerShell scripts (CRLF), and other text files
- Added line ending check and fix script with dry run mode
- Added cross-platform line ending support for Windows and Unix environments

### Changed in 1.0.3

- Improved cross-platform compatibility by standardizing line endings:
  - Windows-specific files (PowerShell scripts) use CRLF
  - Unix-style files (shell scripts, Dockerfile) use LF
  - Documentation and configuration files use LF for better Git compatibility
- Enhanced `.gitattributes` integration with automated line ending management

### Fixed in 1.0.3

- Fixed line endings in shell scripts and configuration files
- Fixed line endings in Dockerfile and environment files
- Fixed line endings in documentation files
- Fixed cross-platform compatibility issues in shell scripts

## [1.0.2] - 2024-03-26

### Added in 1.0.2

- Comprehensive configuration validation with line ending checks
- Variable value validation for environment files
- Improved error handling and user feedback
- Better handling of template vs environment-specific files
- Progress indicators for validation steps

### Changed in 1.0.2

- Enhanced configuration validation script structure
- Improved error messages and validation feedback
- Better handling of file permissions
- More detailed validation output

### Fixed in 1.0.2

- Line ending validation for shell scripts
- Variable value pattern matching
- File permission checks for Windows environment
- Template file validation

## [1.0.1] - 2024-03-26

### Added in 1.0.1

- Version management script for consistent versioning
- Dry run mode for version updates
- Automatic git tag creation
- Version validation
- Comprehensive documentation for version management
- Changelog management

### Changed in 1.0.1

- Updated from original Microsoft tutorial
- Improved script reliability
- Enhanced error messages
- Standardized version format across files

### Fixed in 1.0.1

- Line ending issues in bash scripts
- Error handling in PowerShell scripts
- Configuration validation issues
- Version inconsistency across files

## [1.0.0] - 2024-03-26

### Added in 1.0.0

- Initial release
- Fixed line ending issues in bash scripts
- Improved error handling in PowerShell scripts
- Added comprehensive documentation
- Added configuration validation
- Added logging and monitoring
- Added security best practices
- Added testing and validation
- Added user experience improvements

### Changed in 1.0.0

- Updated from original Microsoft tutorial
- Improved script reliability
- Enhanced error messages

### Fixed in 1.0.0

- Line ending issues in bash scripts
- Error handling in PowerShell scripts
- Configuration validation issues

[Unreleased]: https://github.com/pstackebrandt/aci-helloworld/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/pstackebrandt/aci-helloworld/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/pstackebrandt/aci-helloworld/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/pstackebrandt/aci-helloworld/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/pstackebrandt/aci-helloworld/releases/tag/v1.0.0
