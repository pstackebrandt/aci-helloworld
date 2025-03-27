# Version Management

This project uses semantic versioning (MAJOR.MINOR.PATCH) and includes a version management script to ensure consistent versioning across all files.

## Usage

To update the version number across the project:

```powershell
# Basic usage
.\scripts\Update-ProjectVersion.ps1 -NewVersion "1.0.1"

# With changelog message
.\scripts\Update-ProjectVersion.ps1 -NewVersion "1.0.1" -ChangelogMessage "- Added new feature X"

# Preview changes without making them (dry run)
.\scripts\Update-ProjectVersion.ps1 -NewVersion "1.0.1" -DryRun
```

## What Gets Updated

The script updates version numbers in:

- `app/package.json`
- `README.md`
- `Dockerfile`
- `docs/CHANGELOG.md` (if changelog message is provided)

## Version Number Format

Version numbers must follow semantic versioning:

- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality additions
- PATCH version for backwards-compatible bug fixes

Example: `1.0.0`

## Git Tags

The script automatically creates a git tag for each version update:

- Format: `v1.0.0`
- Tag message: "Release version 1.0.0"

## Dry Run Mode

The `-DryRun` switch allows you to preview changes without making them:

- Shows current and new content for each file
- Displays what would be added to the changelog
- Indicates what git tag would be created
- No actual changes are made to files
- Useful for verifying changes before applying them

Example output:

```text
DRY RUN MODE - No changes will be made
Updating version to 1.0.1...

Would update app/package.json:
Current content: "version": "1.0.0"
New content: "version": "1.0.1"

Would update CHANGELOG.md:
New entry to be added: ## [1.0.1] - 2024-03-26...

Would create git tag: v1.0.1

Version update complete!
This was a dry run - no changes were made
```

## Best Practices

1. Always use the version management script to update versions
2. Include meaningful changelog messages
3. Follow semantic versioning guidelines
4. Test the application after version updates
5. Commit changes and push tags after version updates
6. Use dry run mode to verify changes before applying them

## Manual Updates

If you need to manually update version numbers, ensure you update all files:

1. `app/package.json`
2. `README.md`
3. `Dockerfile`
4. `docs/CHANGELOG.md`
