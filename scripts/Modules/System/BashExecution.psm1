# =============================================================================
# Bash Execution Module
# =============================================================================
# Purpose:
#   Provides functions for executing bash scripts in WSL or Git Bash
# =============================================================================

function Initialize-BashEnvironment {
    [CmdletBinding()]
    param()
    
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

    return @{
        UseWsl = $useWsl
        GitBashPath = $gitBashPath
    }
}

function Invoke-BashScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory=$false)]
        [string]$Arguments = ""
    )
    
    $env = Initialize-BashEnvironment
    Write-Host "Running $ScriptPath $Arguments..." -ForegroundColor Cyan
    
    if ($env.UseWsl) {
        # Convert Windows path to WSL path
        $wslPath = $ScriptPath -replace '\\', '/' -replace '^C:', '/mnt/c'
        wsl bash $wslPath $Arguments
    }
    else {
        & $env.GitBashPath -c "cd '$($PWD.Path -replace '\\', '/')' && ./$($ScriptPath -replace '\\', '/') $Arguments"
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error running $ScriptPath. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Export-ModuleMember -Function Initialize-BashEnvironment, Invoke-BashScript 