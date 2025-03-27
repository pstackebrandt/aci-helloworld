# =============================================================================
# Configuration Module
# =============================================================================
# Purpose:
#   Provides functions for validating configuration files and environment variables
# =============================================================================

function Test-EnvironmentFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        
        [Parameter(Mandatory=$true)]
        [string[]]$RequiredVars
    )

    if (-not (Test-Path $FilePath)) {
        Write-Error "Environment file ${FilePath} not found"
        return $false
    }

    $content = Get-Content $FilePath -Raw
    $missingVars = @()

    foreach ($var in $RequiredVars) {
        if (-not ($content -match "export $var=")) {
            $missingVars += $var
        }
    }

    if ($missingVars.Count -gt 0) {
        Write-Error "Missing required variables in ${FilePath}: $($missingVars -join ', ')"
        return $false
    }

    return $true
}

function Test-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$RequiredFiles = @(
            "config/acr-env-template.sh",
            "config/acr-env.sh"
        ),
        
        [Parameter(Mandatory=$false)]
        [string[]]$RequiredVariables = @(
            "containerRegistry",
            "servicePrincipal",
            "ACR_ROLE"
        )
    )

    $allValid = $true

    # Check required files
    foreach ($file in $RequiredFiles) {
        Write-Host "`nChecking ${file}..." -ForegroundColor Gray
        if (-not (Test-EnvironmentFile -FilePath $file -RequiredVars $RequiredVariables)) {
            $allValid = $false
        }
    }

    return $allValid
}

Export-ModuleMember -Function Test-EnvironmentFile, Test-Configuration 