# =============================================================================
# Configuration Validation Script
# =============================================================================
# Purpose:
#   This script validates configuration files and environment variables
#
# Usage:
#   .\Tools\Validate-Config.ps1
#
# Features:
#   - Validates environment files
#   - Checks for required variables
#   - Validates file permissions
#   - Reports configuration issues
# =============================================================================

# Import required modules
Import-Module $PSScriptRoot\..\Modules\Configuration\Configuration.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\FileSystem\FileSystem.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\FileSystem\GitIgnore.psm1 -Force

# Main execution
Write-Host "`nConfiguration Validation" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

$allValid = $true

# Check configuration files
$allValid = $allValid -and (Test-Configuration)

# Check file permissions for sensitive files
$sensitiveFiles = @(
    "config/acr-env.sh",
    "config/secrets/*.env"
)

foreach ($pattern in $sensitiveFiles) {
    $files = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Write-Host "`nChecking permissions for $($file.Name)..." -ForegroundColor Gray
        try {
            $acl = Get-Acl $file.FullName
            if (-not $acl.AreAccessRulesProtected) {
                Write-Warning "${file} does not have restricted permissions"
                $allValid = $false
            }
        }
        catch {
            Write-Error "Error checking permissions for ${file}: $_"
            $allValid = $false
        }
    }
}

# Check .gitignore entries
$requiredPatterns = @(
    "config/secrets/",
    "config/acr-env.sh"
)

foreach ($pattern in $requiredPatterns) {
    if (-not (Test-GitIgnorePattern -Pattern $pattern)) {
        Write-Warning "Pattern '$pattern' not found in .gitignore"
        $allValid = $false
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
if ($allValid) {
    Write-Host "All configuration files are valid!" -ForegroundColor Green
} else {
    Write-Host "Configuration validation failed. Please fix the issues above." -ForegroundColor Red
    exit 1
} 