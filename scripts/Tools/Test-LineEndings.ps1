# =============================================================================
# Line Ending Check and Normalization Script
# =============================================================================
# Purpose:
#   This script checks and optionally fixes line endings in files
#
# Usage:
#   # Check line endings without making changes
#   .\Test-LineEndings.ps1
#
#   # Fix line endings
#   .\Test-LineEndings.ps1 -Fix
#
#   # Preview changes without making them (dry run)
#   .\Test-LineEndings.ps1 -Fix -DryRun
#
#   # Check specific directory
#   .\Test-LineEndings.ps1 -Path ".\src"
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Fix,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [string]$Path = "."
)

# Import line endings module
$modulePath = Join-Path $PSScriptRoot "..\Modules\LineEndings\LineEndings.psm1"
Import-Module $modulePath -Force

# Load configuration
$configPath = Join-Path $PSScriptRoot "..\Modules\LineEndings\FileTypes.psd1"
$config = Import-PowerShellDataFile $configPath
$FileTypes = $config.FileTypes

# Main execution
Write-Host "`nLine Ending Check" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host "------------------------------------" -ForegroundColor Yellow
}

$allValid = $true
foreach ($pattern in $FileTypes.Keys) {
    Write-Host "`nChecking ${pattern}..." -ForegroundColor Gray
    $files = Get-ChildItem -Path $Path -Recurse -Filter $pattern -File
    foreach ($file in $files) {
        $isValid = Test-FileLineEndings -FilePath $file.FullName -ExpectedEnding $FileTypes[$pattern]
        if (-not $isValid) { $allValid = $false }
        
        if ($Fix -and -not $isValid) {
            Set-FileLineEndings -FilePath $file.FullName -ExpectedEnding $FileTypes[$pattern] -DryRun $DryRun
        }
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
if ($allValid) {
    Write-Host "All files have correct line endings!" -ForegroundColor Green
} else {
    if ($Fix) {
        if ($DryRun) {
            Write-Host "Preview: Files that would be fixed are listed above." -ForegroundColor Yellow
        } else {
            Write-Host "Fixed line endings in files with issues." -ForegroundColor Green
        }
    } else {
        Write-Host "Some files have incorrect line endings. Use -Fix to fix them." -ForegroundColor Yellow
    }
} 