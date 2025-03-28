#Requires -Version 5.0
<#
.SYNOPSIS
    Updates the CHANGELOG.md file based on staged changes in Git.

.DESCRIPTION
    This script helps you update the CHANGELOG.md file by:
    1. Showing which files are staged for commit
    2. Allowing you to generate summaries for the changelog
    3. Inserting changes into the Unreleased section

.PARAMETER DryRun
    If specified, shows what would be changed without actually modifying the changelog.

.PARAMETER AutoGenerate
    If specified, attempts to automatically generate changelog entries based on staged files.

.EXAMPLE
    .\Update-ChangelogFromStaged.ps1
    Shows staged files and guides you through updating the changelog.

.EXAMPLE
    .\Update-ChangelogFromStaged.ps1 -DryRun
    Shows what would be added to the changelog without making changes.

.EXAMPLE
    .\Update-ChangelogFromStaged.ps1 -AutoGenerate
    Automatically generates changelog entries based on staged files.

.NOTES
    Author: Your Name
    Date:   $(Get-Date -Format "yyyy-MM-dd")
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [switch]$AutoGenerate
)

# Define paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$changelogPath = Join-Path $repoRoot "docs\CHANGELOG.md"
$stagedChangesScript = Join-Path $scriptDir "Get-StagedChanges.ps1"

# Check if changelog exists
if (-not (Test-Path $changelogPath)) {
    Write-Error "Changelog file not found at $changelogPath"
    exit 1
}

# Function to check if changes are minor documentation updates
function Test-IsMinorDocumentationChange {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        
        [Parameter(Mandatory = $true)]
        [string]$Status
    )
    
    # Check if it's a markdown file
    if ($FileName -match '\.md$') {
        # If it's a new file or deleted file, it's not a minor change
        if ($Status -eq "Added" -or $Status -eq "Deleted") {
            return $false
        }
        
        # For modified files, we consider it minor if it's just formatting
        # In a future enhancement, we could check the git diff to determine
        # if the changes are truly minor (e.g., only whitespace, formatting, or typo fixes)
        # For now, we'll consider all documentation modifications as significant
        return $false
    }
    
    return $false
}

# Run Get-StagedChanges.ps1 script if it exists
function Get-StagedFilesList {
    if (Test-Path $stagedChangesScript) {
        # Get the JSON data and convert it
        $json = & $stagedChangesScript -Format JSON
        Write-Host "Raw JSON from Get-StagedChanges:" -ForegroundColor Cyan
        Write-Host $json
        
        $files = $json | ConvertFrom-Json
        
        # Show details about empty entries
        $emptyFiles = $files | Where-Object { [string]::IsNullOrEmpty($_.File) }
        if ($emptyFiles) {
            Write-Host "`nFiles with empty names:" -ForegroundColor Yellow
            $emptyFiles | ForEach-Object {
                Write-Host "Status: $($_.Status), Raw data: $($_ | ConvertTo-Json)"
            }
        }
        
        # Count empty entries for a single warning
        $emptyCount = $emptyFiles.Count
        if ($emptyCount -gt 0) {
            Write-Warning "Skipped $emptyCount entries with empty file names"
        }
        
        # Return only files with non-empty names
        $validFiles = $files | Where-Object { -not [string]::IsNullOrEmpty($_.File) }
        
        # Display the valid files for the user
        if ($validFiles.Count -gt 0) {
            Write-Host "`nTotal: $($validFiles.Count) file(s) staged"
            $validFiles | ForEach-Object {
                Write-Host "$($_.Status): $($_.File)"
            }
            Write-Host ""
        }
        
        return $validFiles
    } else {
        Write-Error "Staged changes script not found at $stagedChangesScript"
        exit 1
    }
}

# Function to extract file extensions
function Get-FileExtensionCategory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )
    
    $extension = [System.IO.Path]::GetExtension($FileName).ToLower()
    
    switch -Wildcard ($extension) {
        ".ps1" { return "PowerShell scripts" }
        ".sh" { return "shell scripts" }
        ".md" { return "documentation" }
        ".json" { return "configuration files" }
        ".yml" { return "configuration files" }
        ".yaml" { return "configuration files" }
        ".js" { return "JavaScript files" }
        ".css" { return "CSS files" }
        ".html" { return "HTML files" }
        ".cs" { return "C# files" }
        ".csproj" { return "project files" }
        ".sln" { return "solution files" }
        ".gitattributes" { return "Git configuration files" }
        ".gitignore" { return "Git configuration files" }
        ".dockerfile" { return "Docker files" }
        "*" { return "files" }
    }
}

# Function to generate changelog entries based on file types and changes
function Get-AutoGeneratedChanges {
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$StagedFiles
    )
    
    $added = @()
    $changed = @()
    $fixed = @()
    
    # Group files by category for better summarization
    $filesByCategory = @{}
    foreach ($file in $StagedFiles) {
        if ([string]::IsNullOrEmpty($file.File)) {
            Write-Warning "Skipping file with empty name"
            continue
        }
        
        $category = Get-FileExtensionCategory -FileName $file.File
        if (-not $filesByCategory.ContainsKey($category)) {
            $filesByCategory[$category] = @()
        }
        $filesByCategory[$category] += $file
    }
    
    # Process each category
    foreach ($category in $filesByCategory.Keys) {
        $categoryFiles = $filesByCategory[$category]
        $addedInCategory = $categoryFiles | Where-Object { $_.Status -eq "Added" }
        $modifiedInCategory = $categoryFiles | Where-Object { $_.Status -eq "Modified" }
        $deletedInCategory = $categoryFiles | Where-Object { $_.Status -eq "Deleted" }
        
        # Skip minor documentation changes for all change types
        $hasOnlyMinorChanges = $true
        $allFiles = @()
        if ($addedInCategory) { $allFiles += $addedInCategory }
        if ($modifiedInCategory) { $allFiles += $modifiedInCategory }
        if ($deletedInCategory) { $allFiles += $deletedInCategory }
        
        foreach ($file in $allFiles) {
            if (-not (Test-IsMinorDocumentationChange -FileName $file.File -Status $file.Status)) {
                $hasOnlyMinorChanges = $false
                break
            }
        }
        
        if ($hasOnlyMinorChanges -and $categoryFiles.Count -gt 0) {
            $fileList = $categoryFiles.File -join ', '
            Write-Host "Skipping minor documentation changes in: $fileList" -ForegroundColor Yellow
            continue
        }
        
        # Generate meaningful entries
        if ($addedInCategory.Count -gt 0) {
            if ($addedInCategory.Count -eq 1) {
                $fileName = [System.IO.Path]::GetFileName($addedInCategory[0].File)
                switch ($category) {
                    "PowerShell scripts" { 
                        $added += "- Added new PowerShell script for automation: ${fileName}"
                    }
                    "shell scripts" {
                        $added += "- Added new shell script for system operations: ${fileName}"
                    }
                    "documentation" {
                        $added += "- Added documentation for $([System.IO.Path]::GetFileNameWithoutExtension($fileName))"
                    }
                    "configuration files" {
                        $added += "- Added configuration for $([System.IO.Path]::GetFileNameWithoutExtension($fileName))"
                    }
                    default {
                        $added += "- Added new ${category}: ${fileName}"
                    }
                }
            } else {
                $added += "- Added $($addedInCategory.Count) new ${category}"
            }
        }
        
        if ($modifiedInCategory.Count -gt 0) {
            if ($modifiedInCategory.Count -eq 1) {
                $fileName = [System.IO.Path]::GetFileName($modifiedInCategory[0].File)
                switch ($category) {
                    "PowerShell scripts" {
                        $changed += "- Enhanced PowerShell script functionality in ${fileName}"
                    }
                    "shell scripts" {
                        $changed += "- Improved shell script operations in ${fileName}"
                    }
                    "documentation" {
                        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
                        $changed += "- Updated documentation for ${baseName}"
                    }
                    "configuration files" {
                        $changed += "- Updated configuration in ${fileName}"
                    }
                    default {
                        $changed += "- Modified ${category}: ${fileName}"
                    }
                }
            } else {
                $changed += "- Updated multiple ${category} ($($modifiedInCategory.Count) files)"
            }
        }
        
        if ($deletedInCategory.Count -gt 0) {
            if ($deletedInCategory.Count -eq 1) {
                $fileName = [System.IO.Path]::GetFileName($deletedInCategory[0].File)
                $fixed += "- Removed unused ${category}: ${fileName}"
            } else {
                $fixed += "- Cleaned up $($deletedInCategory.Count) unused ${category}"
            }
        }
    }
    
    return @{
        Added = $added
        Changed = $changed
        Fixed = $fixed
    }
}

# Function to update the changelog
function Update-Changelog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ChangelogPath,
        
        [Parameter(Mandatory = $false)]
        [string[]]$AddedEntries = @(),
        
        [Parameter(Mandatory = $false)]
        [string[]]$ChangedEntries = @(),
        
        [Parameter(Mandatory = $false)]
        [string[]]$FixedEntries = @(),
        
        [Parameter(Mandatory = $false)]
        [switch]$DryRun
    )
    
    $content = Get-Content $ChangelogPath -Raw
    
    # Find the Unreleased section
    $unreleasedHeaderPattern = '## \[Unreleased\]'
    
    if ($content -match $unreleasedHeaderPattern) {
        # Find where the Unreleased section ends (next ## header)
        $unreleasedSectionPattern = '(?s)(## \[Unreleased\].*?)(?=\n## \[|$)'
        if ($content -match $unreleasedSectionPattern) {
            $unreleasedSection = $Matches[1]
            
            # Process Added section
            if ($AddedEntries.Count -gt 0) {
                $addedEntries = $AddedEntries -join "`n"
                if ($unreleasedSection -match '(### Added\s*\n*)') {
                    $newUnreleasedSection = $unreleasedSection -replace '(### Added\s*\n*)', "`$1$addedEntries`n"
                    $content = $content.Replace($unreleasedSection, $newUnreleasedSection)
                    $unreleasedSection = $newUnreleasedSection
                }
            }
            
            # Process Changed section
            if ($ChangedEntries.Count -gt 0) {
                $changedEntries = $ChangedEntries -join "`n"
                if ($unreleasedSection -match '(### Changed\s*\n*)') {
                    $newUnreleasedSection = $unreleasedSection -replace '(### Changed\s*\n*)', "`$1$changedEntries`n"
                    $content = $content.Replace($unreleasedSection, $newUnreleasedSection)
                    $unreleasedSection = $newUnreleasedSection
                }
            }
            
            # Process Fixed section
            if ($FixedEntries.Count -gt 0) {
                $fixedEntries = $FixedEntries -join "`n"
                if ($unreleasedSection -match '(### Fixed\s*\n*)') {
                    $newUnreleasedSection = $unreleasedSection -replace '(### Fixed\s*\n*)', "`$1$fixedEntries`n"
                    $content = $content.Replace($unreleasedSection, $newUnreleasedSection)
                }
            }
        }
        
        # Ensure exactly one newline at the end of the file
        if (-not $content.EndsWith("`n")) {
            $content += "`n"
        } elseif ($content.EndsWith("`n`n")) {
            $content = $content.TrimEnd() + "`n"
        }
        
        if ($DryRun) {
            Write-Host "`nChanges that would be made to the changelog:" -ForegroundColor Cyan
            
            if ($AddedEntries.Count -gt 0) {
                Write-Host "`n### Added" -ForegroundColor Green
                $AddedEntries | ForEach-Object { Write-Host $_ }
            }
            
            if ($ChangedEntries.Count -gt 0) {
                Write-Host "`n### Changed" -ForegroundColor Yellow
                $ChangedEntries | ForEach-Object { Write-Host $_ }
            }
            
            if ($FixedEntries.Count -gt 0) {
                Write-Host "`n### Fixed" -ForegroundColor Magenta
                $FixedEntries | ForEach-Object { Write-Host $_ }
            }
        } else {
            Set-Content -Path $ChangelogPath -Value $content -NoNewline
            Write-Host "Changelog updated successfully!" -ForegroundColor Green
        }
    } else {
        Write-Error "Could not find Unreleased section in the changelog."
        exit 1
    }
}

# Main script execution
Write-Host "Checking for staged changes..." -ForegroundColor Cyan
$stagedFiles = Get-StagedFilesList

if ($null -eq $stagedFiles -or $stagedFiles.Count -eq 0) {
    Write-Host "No files are currently staged for commit. Stage some changes first." -ForegroundColor Yellow
    exit 0
}

# Auto-generate or manually collect changelog entries
$addedEntries = @()
$changedEntries = @()
$fixedEntries = @()

if ($AutoGenerate) {
    Write-Host "Auto-generating changelog entries based on staged files..." -ForegroundColor Cyan
    $generatedChanges = Get-AutoGeneratedChanges -StagedFiles $stagedFiles
    
    $addedEntries = $generatedChanges.Added
    $changedEntries = $generatedChanges.Changed
    $fixedEntries = $generatedChanges.Fixed
} else {
    # Manual entry mode
    Write-Host "`nEnter changelog entries (leave blank to finish each section):" -ForegroundColor Cyan
    
    Write-Host "`nAdded entries:" -ForegroundColor Green
    do {
        $entry = Read-Host "- "
        if ($entry -ne '') {
            $addedEntries += "- $entry"
        }
    } while ($entry -ne '')
    
    Write-Host "`nChanged entries:" -ForegroundColor Yellow
    do {
        $entry = Read-Host "- "
        if ($entry -ne '') {
            $changedEntries += "- $entry"
        }
    } while ($entry -ne '')
    
    Write-Host "`nFixed entries:" -ForegroundColor Magenta
    do {
        $entry = Read-Host "- "
        if ($entry -ne '') {
            $fixedEntries += "- $entry"
        }
    } while ($entry -ne '')
}

# Update the changelog
Update-Changelog -ChangelogPath $changelogPath `
                -AddedEntries $addedEntries `
                -ChangedEntries $changedEntries `
                -FixedEntries $fixedEntries `
                -DryRun:$DryRun 