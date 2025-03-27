# Changelog Management Tools

This directory contains tools for managing changelog entries and Git staging.

## Get-StagedChanges.ps1

This tool shows which files are currently staged for commit in the Git repository.

### Usage

```powershell
# Basic usage - show staged files
.\Get-StagedChanges.ps1

# Show staged files with diff content
.\Get-StagedChanges.ps1 -ShowDiff

# Get staged files in JSON format
.\Get-StagedChanges.ps1 -Format JSON

# Get staged files in CSV format
.\Get-StagedChanges.ps1 -Format CSV
```

### Features

- Shows status of each staged file (Added, Modified, Deleted, etc.)
- Displays a summary count of staged files
- Optional diff view of file changes
- Multiple output formats (Text, JSON, CSV)

## Update-ChangelogFromStaged.ps1

This tool helps you update the CHANGELOG.md file based on the files that are staged for commit.

### Usage

```powershell
# Interactive mode - prompts for changelog entries
..\Update-ChangelogFromStaged.ps1

# Preview changes without making them
..\Update-ChangelogFromStaged.ps1 -DryRun

# Automatically generate changelog entries based on file types
..\Update-ChangelogFromStaged.ps1 -AutoGenerate
```

### Features

- Shows which files are staged for commit
- Interactive prompts for Added, Changed, and Fixed entries
- Auto-generation of changelog entries based on file types and changes
- Dry run mode to preview changes without modifying the changelog
- Properly updates the Unreleased section of the changelog

## Best Practices for Changelog Management

1. Stage your changes before running the changelog update tool
2. Use descriptive changelog entries that explain the impact of changes
3. Categorize changes correctly (Added, Changed, Fixed)
4. Review auto-generated entries before committing
5. Keep the Unreleased section updated with all changes
6. When releasing, move Unreleased entries to a new version section

## Integration with Update-ProjectVersion.ps1

When releasing a new version, follow this workflow:

1. Update the changelog with all changes using `Update-ChangelogFromStaged.ps1`
2. Commit these changes
3. Run `Update-ProjectVersion.ps1` to create a new version
4. The new version will automatically incorporate the Unreleased changes 