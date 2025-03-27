# Version Management Script for ACI Hello World
# This script updates version numbers across the project and manages the changelog
#
# Examples:
#   # Basic version update
#   .\Update-ProjectVersion.ps1 -NewVersion "1.0.1"
#
#   # Update version with changelog message
#   .\Update-ProjectVersion.ps1 -NewVersion "1.0.1" -ChangelogMessage "- Added new feature X"
#
#   # Preview changes without making them (dry run)
#   .\Update-ProjectVersion.ps1 -NewVersion "1.0.1" -DryRun
#
#   # Update version with multiple changelog entries
#   .\Update-ProjectVersion.ps1 -NewVersion "1.0.1" -ChangelogMessage @"
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
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Configuration
# Maps file paths to their version pattern for regex replacement
$FilesToUpdate = @{
    "app/package.json" = '"version":\s*"'
    "README.md" = "Version:\s*"
    "Dockerfile" = 'LABEL\s+version=\s*"'
    "scripts/Update-ProjectVersion.ps1" = "# Version:\s*"
}

# Function to validate semantic version
function Test-SemanticVersion {
    param(
        [string]$Version
    )

    $parts = $Version -split '\.'
    if ($parts.Count -ne 3) { return $false }
    
    foreach ($part in $parts) {
        if (-not ($part -match '^\d+$')) { return $false }
    }
    return $true
}

# Function to backup file
function Backup-File {
    param(
        [string]$FilePath
    )

    if (Test-Path $FilePath) {
        $backupPath = "$FilePath.bak"
        try {
            Copy-Item -Path $FilePath -Destination $backupPath -Force
            return $backupPath
        } catch {
            Write-Host "Warning: Could not create backup for ${FilePath}" -ForegroundColor Yellow
            return $null
        }
    }
    return $null
}

# Function to restore file from backup
function Restore-File {
    param(
        [string]$FilePath,
        [string]$BackupPath
    )

    if (Test-Path $BackupPath) {
        Copy-Item -Path $BackupPath -Destination $FilePath -Force
        Remove-Item $BackupPath -Force
        return $true
    }
    return $false
}

# Function to check if all files have the same version
function Test-VersionConsistency {
    $versions = @{}
    foreach ($file in $FilesToUpdate.GetEnumerator()) {
        if (Test-Path $file.Key) {
            $content = Get-Content $file.Key -Raw
            $pattern = $file.Value
            if ($content -match "${pattern}(\d+\.\d+\.\d+)") {
                $versions[$file.Key] = $matches[1]
            }
        }
    }

    $uniqueVersions = $versions.Values | Select-Object -Unique
    if ($uniqueVersions.Count -gt 1) {
        Write-Host "Warning: Inconsistent versions found:" -ForegroundColor Yellow
        foreach ($file in $versions.GetEnumerator()) {
            Write-Host "  $($file.Key): $($file.Value)" -ForegroundColor Yellow
        }
        return $false
    }
    return $true
}

# Function to update version in a file
function Update-VersionInFile {
    param(
        [string]$FilePath,
        [string]$VersionPattern,
        [string]$NewVersion,
        [bool]$DryRun,
        [bool]$Force
    )

    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $oldContent = $content
        $content = $content -replace "($VersionPattern)(\d+\.\d+\.\d+)", "`${1}$NewVersion"
        
        if ($DryRun) {
            Write-Host "`nWould update ${FilePath}:" -ForegroundColor Yellow
            Write-Host "Current content: $oldContent" -ForegroundColor Gray
            Write-Host "New content: $content" -ForegroundColor Green
        } else {
            $backupPath = Backup-File $FilePath
            try {
                Set-Content -Path $FilePath -Value $content
                Write-Host "Updated version in ${FilePath}" -ForegroundColor Green
                if ($backupPath) { Remove-Item $backupPath -Force }
            } catch {
                Write-Host "Error updating ${FilePath}: $_" -ForegroundColor Red
                if ($backupPath) { Restore-File $FilePath $backupPath }
                throw
            }
        }
    } else {
        Write-Host "File not found: ${FilePath}" -ForegroundColor Yellow
    }
}

# Function to update CHANGELOG.md
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
            $backupPath = Backup-File $changelogPath
            try {
                Set-Content -Path $changelogPath -Value $newContent
                Write-Host "Updated CHANGELOG.md" -ForegroundColor Green
                if ($backupPath) { Remove-Item $backupPath -Force }
            } catch {
                Write-Host "Error updating ${changelogPath}: $_" -ForegroundColor Red
                if ($backupPath) { Restore-File $changelogPath $backupPath }
                throw
            }
        }
    }
}

# Main execution
Write-Host "`nVersion Management Script" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}

# Validate version format
if (-not (Test-SemanticVersion $NewVersion)) {
    Write-Host "Error: Invalid version format. Use MAJOR.MINOR.PATCH" -ForegroundColor Red
    exit 1
}

# Check version consistency
if (-not $Force -and -not (Test-VersionConsistency)) {
    Write-Host "`nError: Inconsistent versions found. Use -Force to override." -ForegroundColor Red
    exit 1
}

Write-Host "Updating version to $NewVersion..." -ForegroundColor Cyan

# Update version in all configured files
foreach ($file in $FilesToUpdate.GetEnumerator()) {
    Update-VersionInFile -FilePath $file.Key -VersionPattern $file.Value -NewVersion $NewVersion -DryRun $DryRun -Force $Force
}

# Update CHANGELOG.md if message is provided
if ($ChangelogMessage) {
    Update-Changelog -NewVersion $NewVersion -Message $ChangelogMessage -DryRun $DryRun
}

# Create git tag
if (-not $DryRun) {
    try {
        # Check if tag exists
        $tagExists = git tag -l "v$NewVersion"
        if ($tagExists) {
            if ($Force) {
                git tag -d "v$NewVersion"
                git tag -a "v$NewVersion" -m "Release version $NewVersion"
                Write-Host "Updated git tag v$NewVersion" -ForegroundColor Green
            } else {
                Write-Host "Git tag v$NewVersion already exists. Use -Force to override." -ForegroundColor Yellow
            }
        } else {
            git tag -a "v$NewVersion" -m "Release version $NewVersion"
            Write-Host "Created git tag v$NewVersion" -ForegroundColor Green
        }
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
