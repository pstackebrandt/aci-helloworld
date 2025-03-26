# Version Management Script for ACI Hello World
# This script updates version numbers across the project and manages the changelog
#
# Examples:
#   # Basic version update
#   .\Update-Version.ps1 -NewVersion "1.0.1"
#
#   # Update version with changelog message
#   .\Update-Version.ps1 -NewVersion "1.0.1" -ChangelogMessage "- Added new feature X"
#
#   # Preview changes without making them (dry run)
#   .\Update-Version.ps1 -NewVersion "1.0.1" -DryRun
#
#   # Update version with multiple changelog entries
#   .\Update-Version.ps1 -NewVersion "1.0.1" -ChangelogMessage @"
#   - Added new feature X
#   - Fixed bug in Y
#   - Updated documentation
#   "@

param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$NewVersion,

    [Parameter(Mandatory=$false)]
    [string]$ChangelogMessage,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Configuration
# Maps file paths to their version pattern for regex replacement
$FilesToUpdate = @{
    "app/package.json" = "version"
    "README.md" = "Version: "
    "Dockerfile" = "LABEL version="
}

# Function to update version in a file
# Parameters:
#   FilePath: Path to the file to update
#   VersionPattern: Pattern to match version in the file
#   NewVersion: New version number to set
#   DryRun: Whether to preview changes without making them
function Update-VersionInFile {
    param(
        [string]$FilePath,
        [string]$VersionPattern,
        [string]$NewVersion,
        [bool]$DryRun
    )

    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $oldContent = $content
        $content = $content -replace "($VersionPattern)`"(\d+\.\d+\.\d+)`"", "`$1`"$NewVersion`""
        
        if ($DryRun) {
            Write-Host "`nWould update ${FilePath}:" -ForegroundColor Yellow
            Write-Host "Current content: $oldContent" -ForegroundColor Gray
            Write-Host "New content: $content" -ForegroundColor Green
        } else {
            Set-Content -Path $FilePath -Value $content
            Write-Host "Updated version in $FilePath" -ForegroundColor Green
        }
    } else {
        Write-Host "File not found: $FilePath" -ForegroundColor Yellow
    }
}

# Function to update CHANGELOG.md
# Parameters:
#   NewVersion: New version number
#   Message: Changelog message to add
#   DryRun: Whether to preview changes without making them
function Update-Changelog {
    param(
        [string]$NewVersion,
        [string]$Message,
        [bool]$DryRun
    )

    $changelogPath = "docs/CHANGELOG.md"
    if (Test-Path $changelogPath) {
        $date = Get-Date -Format "yyyy-MM-dd"
        $changelogContent = Get-Content $changelogPath -Raw
        $newEntry = @"

## [$NewVersion] - $date

### Added
$Message

"@
        $newContent = $changelogContent -replace "## \[Unreleased\]", $newEntry
        
        if ($DryRun) {
            Write-Host "`nWould update CHANGELOG.md:" -ForegroundColor Yellow
            Write-Host "New entry to be added: $newEntry" -ForegroundColor Green
        } else {
            Set-Content -Path $changelogPath -Value $newContent
            Write-Host "Updated CHANGELOG.md" -ForegroundColor Green
        }
    }
}

# Main execution
Write-Host "`nVersion Management Script" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}
Write-Host "Updating version to $NewVersion..." -ForegroundColor Cyan

# Update version in all configured files
foreach ($file in $FilesToUpdate.GetEnumerator()) {
    Update-VersionInFile -FilePath $file.Key -VersionPattern $file.Value -NewVersion $NewVersion -DryRun $DryRun
}

# Update CHANGELOG.md if message is provided
if ($ChangelogMessage) {
    Update-Changelog -NewVersion $NewVersion -Message $ChangelogMessage -DryRun $DryRun
}

# Create git tag
if (-not $DryRun) {
    try {
        git tag -a "v$NewVersion" -m "Release version $NewVersion"
        Write-Host "Created git tag v$NewVersion" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create git tag: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`nWould create git tag: v$NewVersion" -ForegroundColor Yellow
}

Write-Host "`nVersion update complete!" -ForegroundColor Green
if ($DryRun) {
    Write-Host "This was a dry run - no changes were made" -ForegroundColor Yellow
} 