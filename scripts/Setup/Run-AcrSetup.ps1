# =============================================================================
# Azure Container Registry Authentication Setup - PowerShell Wrapper
# =============================================================================
# Purpose:
#   This script is a Windows PowerShell wrapper for the bash scripts that 
#   set up Azure Container Registry authentication.
#
# Usage:
#   1. Open PowerShell and navigate to the root directory of the project
#   2. Run: .\scripts\Setup\Run-AcrSetup.ps1
# =============================================================================

# Import required modules
Import-Module $PSScriptRoot\..\Modules\LineEndings\LineEndings.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\Azure\ServicePrincipal.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\System\BashExecution.psm1 -Force
Import-Module $PSScriptRoot\..\Modules\FileSystem\FileSystem.psm1 -Force

# Define environment variable file paths
$EnvTemplatePath = "config\acr-env-template.sh"
$EnvFilePath = "config\acr-env.sh"

# Check line endings in environment files
$config = Import-PowerShellDataFile (Join-Path $PSScriptRoot "..\Modules\LineEndings\FileTypes.psd1")

# Check template file
if (Test-Path $EnvTemplatePath) {
    $isValid = Test-FileLineEndings -FilePath $EnvTemplatePath -ExpectedEnding $config.FileTypes["*.sh"]
    if (-not $isValid) {
        Write-Host "Fixing line endings in $EnvTemplatePath..." -ForegroundColor Yellow
        Set-FileLineEndings -FilePath $EnvTemplatePath -ExpectedEnding $config.FileTypes["*.sh"]
    }
}

# Check environment file if it exists
if (Test-Path $EnvFilePath) {
    $isValid = Test-FileLineEndings -FilePath $EnvFilePath -ExpectedEnding $config.FileTypes["*.sh"]
    if (-not $isValid) {
        Write-Host "Fixing line endings in $EnvFilePath..." -ForegroundColor Yellow
        Set-FileLineEndings -FilePath $EnvFilePath -ExpectedEnding $config.FileTypes["*.sh"]
    }
}

# Check if WSL2 is available
$useWsl = $false
try {
    wsl --status 2>&1
    if ($LASTEXITCODE -eq 0) {
        $useWsl = $true
        Write-Host "WSL2 detected. Will use WSL for running scripts." -ForegroundColor Green
    }
}
catch {
    Write-Host "WSL not detected. Will try to use Git Bash." -ForegroundColor Yellow
}

# Check if Git Bash is available if not using WSL
$gitBashPath = $null
if (-not $useWsl) {
    $possiblePaths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $gitBashPath = $path
            break
        }
    }
    
    if ($gitBashPath) {
        Write-Host "Git Bash found at: $gitBashPath" -ForegroundColor Green
    }
    else {
        Write-Host "Error: Neither WSL nor Git Bash found. Cannot proceed." -ForegroundColor Red
        exit 1
    }
}

# Check if env file exists, if not, prompt to create it
if (-not (Test-Path $EnvFilePath)) {
    Write-Host "Environment file $EnvFilePath not found." -ForegroundColor Yellow
    Write-Host "Creating it from template..." -ForegroundColor Yellow
    
    # Read template
    $template = Get-Content $EnvTemplatePath -Raw
    
    # Prompt for values
    $acrName = Read-Host "Enter your Azure Container Registry name"
    $spName = Read-Host "Enter a name for the Service Principal [acr-service-principal]"
    if ([string]::IsNullOrWhiteSpace($spName)) {
        $spName = "acr-service-principal"
    }
    
    # Replace values in template
    $envContent = $template -replace 'your-acr-name', $acrName -replace 'acr-service-principal', $spName
    
    # Create config directory if it doesn't exist
    $configDir = Split-Path $EnvFilePath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir | Out-Null
    }
    
    # Write to file
    $envContent | Out-File -FilePath $EnvFilePath -Encoding utf8
    Write-Host "Created $EnvFilePath with your values." -ForegroundColor Green
}

# Function to run a bash script
function Invoke-BashScript {
    param (
        [string]$ScriptPath
    )
    
    Write-Host "Running $ScriptPath..." -ForegroundColor Cyan
    
    if ($useWsl) {
        # Convert Windows path to WSL path
        $wslPath = $ScriptPath -replace '\\', '/' -replace '^C:', '/mnt/c'
        wsl bash $wslPath
    }
    else {
        & $gitBashPath -c "cd '$($PWD.Path -replace '\\', '/')' && ./$($ScriptPath -replace '\\', '/')"
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error running $ScriptPath. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Main execution
Write-Host "Azure Container Registry Authentication Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Make sure scripts are executable (WSL only)
if ($useWsl) {
    Write-Host "Setting execute permissions on scripts..." -ForegroundColor Cyan
    wsl chmod +x scripts/*.sh
}

# Run the main setup script
Invoke-BashScript "scripts/setup-acr-auth.sh"

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review the generated credentials in $credentialsFile" -ForegroundColor Yellow
Write-Host "2. Use the Docker login script to authenticate:" -ForegroundColor Yellow
Write-Host "   .\scripts\Operations\Run-DockerLogin.ps1" -ForegroundColor Yellow 