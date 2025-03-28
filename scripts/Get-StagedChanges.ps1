#Requires -Version 5.0
<#
.SYNOPSIS
    Shows files staged for commit in the current Git repository.

.DESCRIPTION
    This script lists all files that are currently staged for commit in the Git repository,
    showing their status (added, modified, deleted) and optionally displaying a summary of changes.

.PARAMETER ShowDiff
    If specified, shows a summary of changes for each staged file.

.PARAMETER Format
    Output format. Valid values: 'Text', 'JSON', 'CSV'. Default is 'Text'.

.EXAMPLE
    .\Get-StagedChanges.ps1
    Lists all staged files with their status.

.EXAMPLE
    .\Get-StagedChanges.ps1 -ShowDiff
    Lists all staged files with their status and shows changes.

.EXAMPLE
    .\Get-StagedChanges.ps1 -Format JSON
    Returns the list of staged files in JSON format.

.NOTES
    Author: Your Name
    Date:   $(Get-Date -Format "yyyy-MM-dd")
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $false)]
    [switch]$ShowDiff,
    
    [Parameter(Position = 1, Mandatory = $false)]
    [ValidateSet('Text', 'JSON', 'CSV')]
    [string]$Format = 'Text'
)

function Test-GitRepository {
    $gitDir = git rev-parse --git-dir 2>$null
    return $LASTEXITCODE -eq 0
}

function Get-StagedFiles {
    # Get list of staged files
    $stagedFiles = git diff --name-status --staged | ForEach-Object {
        $parts = $_ -split "`t"
        $status = $parts[0]
        
        # Handle renamed/copied files which have format: R<score>\told\tnew
        if ($status -match '^R|^C') {
            $filename = $parts[2]  # Use the new filename for renamed/copied files
        } else {
            $filename = $parts[1]
        }
        
        # Skip if we couldn't get a filename
        if ([string]::IsNullOrEmpty($filename)) {
            Write-Warning "Skipping entry with status '$status' - could not determine filename from: $_"
            return
        }
        
        $statusText = switch -Regex ($status) {
            "^A" { "Added" }
            "^M" { "Modified" }
            "^D" { "Deleted" }
            "^R" { "Renamed" }
            "^C" { "Copied" }
            "^U" { "Unmerged" }
            default { $status }
        }
        
        [PSCustomObject]@{
            Status = $statusText
            File = $filename
            OriginalStatus = $status
        }
    } | Where-Object { $null -ne $_ }  # Filter out skipped entries
    
    return $stagedFiles
}

function Get-FileDiff {
    param (
        [Parameter(Mandatory = $true)]
        [string]$File
    )
    
    $diff = git diff --staged --unified=1 -- $File
    return $diff
}

function Format-Output {
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$StagedFiles,
        
        [Parameter(Mandatory = $true)]
        [string]$Format
    )
    
    switch ($Format) {
        'JSON' {
            return $StagedFiles | ConvertTo-Json
        }
        'CSV' {
            return $StagedFiles | ConvertTo-Csv -NoTypeInformation
        }
        default {
            return $StagedFiles
        }
    }
}

# Main script execution
if (-not (Test-GitRepository)) {
    Write-Error "Current directory is not a git repository."
    exit 1
}

$stagedFiles = Get-StagedFiles

if ($null -eq $stagedFiles -or $stagedFiles.Count -eq 0) {
    Write-Host "No files are currently staged for commit." -ForegroundColor Yellow
    exit 0
}

# Format and display output
$outputData = $stagedFiles
$formattedOutput = Format-Output -StagedFiles $outputData -Format $Format

if ($Format -eq 'Text') {
    Write-Host "`nStaged Files for Commit:`n" -ForegroundColor Cyan
    $formattedOutput | Format-Table -AutoSize
    
    Write-Host "Total: $($stagedFiles.Count) file(s) staged" -ForegroundColor Green
    
    if ($ShowDiff) {
        Write-Host "`nChanges in staged files:`n" -ForegroundColor Cyan
        foreach ($file in $stagedFiles) {
            if ($file.Status -ne "Deleted") {
                Write-Host "`n--- $($file.File) ($($file.Status)) ---" -ForegroundColor Magenta
                $diff = Get-FileDiff -File $file.File
                
                # Display a concise diff
                $diffContent = $diff | Select-Object -Skip 4 | Out-String
                if ($diffContent.Length -gt 500) {
                    $diffContent = $diffContent.Substring(0, 500) + "`n... (diff truncated)"
                }
                Write-Host $diffContent
            }
        }
    }
} else {
    Write-Output $formattedOutput
} 