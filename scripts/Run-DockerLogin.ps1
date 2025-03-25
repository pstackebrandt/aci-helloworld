# =============================================================================
# Docker Login to ACR - PowerShell Wrapper
# =============================================================================
# Purpose:
#   This script is a Windows PowerShell wrapper for the bash script that logs 
#   into an Azure Container Registry with Docker.
#
# Usage:
#   1. Open PowerShell and navigate to the root directory of the project
#   2. Run: .\scripts\Run-DockerLogin.ps1
# =============================================================================

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

# Function to run a bash script
function Invoke-BashScript {
    param (
        [string]$ScriptPath,
        [string]$Arguments = ""
    )
    
    Write-Host "Running $ScriptPath $Arguments..." -ForegroundColor Cyan
    
    if ($useWsl) {
        # Convert Windows path to WSL path
        $wslPath = $ScriptPath -replace '\\', '/' -replace '^C:', '/mnt/c'
        wsl bash $wslPath $Arguments
    }
    else {
        & $gitBashPath -c "cd '$($PWD.Path -replace '\\', '/')' && ./$($ScriptPath -replace '\\', '/') $Arguments"
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error running $ScriptPath. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Main execution
Write-Host "Docker Login to Azure Container Registry" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# List available credential files
$credentialsDir = "config\secrets"
if (Test-Path $credentialsDir) {
    $credFiles = Get-ChildItem -Path $credentialsDir -Filter "acr-credentials_*.env" | Sort-Object LastWriteTime -Descending
    
    if ($credFiles.Count -gt 0) {
        Write-Host "Available credential files:" -ForegroundColor Cyan
        for ($i = 0; $i -lt [Math]::Min(5, $credFiles.Count); $i++) {
            Write-Host "[$i] $($credFiles[$i].Name) ($(Get-Date $credFiles[$i].LastWriteTime -Format 'yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow
        }
        
        $selection = Read-Host "Select a file (0-$([Math]::Min(4, $credFiles.Count-1))) or press Enter for most recent"
        
        $selectedFile = ""
        if ([string]::IsNullOrWhiteSpace($selection)) {
            $selectedFile = $credFiles[0].FullName
        }
        elseif ([int]::TryParse($selection, [ref]$null)) {
            $index = [int]$selection
            if ($index -ge 0 -and $index -lt $credFiles.Count) {
                $selectedFile = $credFiles[$index].FullName
            }
        }
        
        if ($selectedFile) {
            # Run the Docker login script with the selected credentials file
            Invoke-BashScript "scripts/docker-login-acr.sh" "`"$($selectedFile -replace '\\', '/')`""
        }
        else {
            Write-Host "Invalid selection." -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "No credential files found in $credentialsDir." -ForegroundColor Red
        Write-Host "Please run .\scripts\Run-AcrSetup.ps1 first." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "Credentials directory $credentialsDir not found." -ForegroundColor Red
    Write-Host "Please run .\scripts\Run-AcrSetup.ps1 first." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nDocker login complete!" -ForegroundColor Green 