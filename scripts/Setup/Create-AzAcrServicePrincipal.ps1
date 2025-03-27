# =============================================================================
# Azure Container Registry Service Principal Creation Script (PowerShell)
# =============================================================================
# Purpose:
#   This script creates a service principal in Azure Active Directory and
#   assigns it permissions to access an Azure Container Registry (ACR).
#   It reads configuration from the acr-env.sh file to maintain consistency
#   with the bash scripts.
#
# Prerequisites:
#   - Az PowerShell module installed
#   - User logged in to Azure with Connect-AzAccount
#   - An existing Azure Container Registry
#
# Usage:
#   .\scripts\Setup\Create-AzAcrServicePrincipal.ps1
# =============================================================================

# Import required modules
Import-Module $PSScriptRoot\..\Modules\Azure\ServicePrincipal.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\FileSystem\GitIgnore.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\LineEndings\LineEndings.psm1 -Force

# Read environment variables from acr-env.sh
$envFilePath = "config/acr-env.sh"
if (-not (Test-Path $envFilePath)) {
    Write-Error "Environment file $envFilePath not found. Please create it from the template."
    exit 1
}

# Check line endings in environment file
$config = Import-PowerShellDataFile (Join-Path $PSScriptRoot "..\Modules\LineEndings\FileTypes.psd1")
$isValid = Test-FileLineEndings -FilePath $envFilePath -ExpectedEnding $config.FileTypes["*.sh"]
if (-not $isValid) {
    Write-Host "Fixing line endings in $envFilePath..." -ForegroundColor Yellow
    Set-FileLineEndings -FilePath $envFilePath -ExpectedEnding $config.FileTypes["*.sh"]
}

# Parse the acr-env.sh file to extract variables
$envContent = Get-Content $envFilePath -Raw
$acrName = if ($envContent -match 'export containerRegistry="([^"]+)"') { $matches[1] } else { $null }
$servicePrincipalName = if ($envContent -match 'export servicePrincipal="([^"]+)"') { $matches[1] } else { $null }
$acrRole = if ($envContent -match 'export ACR_ROLE="([^"]+)"') { $matches[1] } else { "acrpull" }

# Validate required variables
if (-not $acrName) {
    Write-Error "containerRegistry variable not found in $envFilePath"
    exit 1
}
if (-not $servicePrincipalName) {
    Write-Error "servicePrincipal variable not found in $envFilePath"
    exit 1
}

# Use the modular functions
try {
    $sp = New-AcrServicePrincipal -AcrName $acrName -ServicePrincipalName $servicePrincipalName -Role $acrRole
    if ($sp) {
        Save-ServicePrincipalCredentials -ServicePrincipal $sp -AcrName $acrName
        Update-GitIgnore -Pattern "config/secrets/"
        Write-Host "Service principal created and credentials saved successfully!" -ForegroundColor Green
    }
    else {
        Write-Error "Failed to create service principal"
        exit 1
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
} 