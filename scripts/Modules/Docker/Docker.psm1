# =============================================================================
# Docker Operations Module
# =============================================================================
# Purpose:
#   Provides centralized functions for Docker operations with Azure Container
#   Registry (ACR), including environment validation and login functionality.
# =============================================================================

# Validate Docker environment and configuration
function Test-DockerEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$EnvFile = "config/acr-env.sh"
    )

    # Check if environment file exists
    if (-not (Test-Path $EnvFile)) {
        Write-Error "Environment file not found: ${EnvFile}"
        return $false
    }

    # Import LineEndings module and validate line endings
    try {
        Import-Module LineEndings
        if (-not (Test-FileLineEndings -FilePath $EnvFile)) {
            Write-Warning "Line endings in ${EnvFile} need to be fixed"
            Set-FileLineEndings -FilePath $EnvFile -Fix
            if (-not (Test-FileLineEndings -FilePath $EnvFile)) {
                Write-Error "Failed to fix line endings in ${EnvFile}"
                return $false
            }
        }
    }
    catch {
        Write-Error "Failed to validate line endings: $_"
        return $false
    }

    # Validate required environment variables
    $envContent = Get-Content $EnvFile -Raw
    $requiredVars = @(
        'containerRegistry',
        'servicePrincipal',
        'password'
    )

    foreach ($var in $requiredVars) {
        if ($envContent -notmatch "export\s+$var=") {
            Write-Error "Missing required variable in ${EnvFile}: ${var}"
            return $false
        }
    }

    return $true
}

# Connect to Docker registry using environment configuration
function Connect-DockerRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$EnvFile = "config/acr-env.sh",
        
        [Parameter(Mandatory=$false)]
        [switch]$DryRun
    )

    # Validate environment first
    if (-not (Test-DockerEnvironment -EnvFile $EnvFile)) {
        Write-Error "Environment validation failed"
        return $false
    }

    try {
        # Parse environment variables
        $envContent = Get-Content $EnvFile -Raw
        $registry = if ($envContent -match 'export containerRegistry="([^"]+)"') { $matches[1] } else { $null }
        $spName = if ($envContent -match 'export servicePrincipal="([^"]+)"') { $matches[1] } else { $null }
        $password = if ($envContent -match 'export password="([^"]+)"') { $matches[1] } else { $null }

        if ($DryRun) {
            Write-Host "Would execute: docker login ${registry}.azurecr.io -u $spName" -ForegroundColor Cyan
            Write-Host "(password hidden for security)" -ForegroundColor Cyan
            return $true
        }

        # Execute login
        Write-Host "Logging in to ${registry}.azurecr.io..." -ForegroundColor Cyan
        $loginCmd = "docker login ${registry}.azurecr.io -u $spName -p $password"
        Invoke-Expression $loginCmd
        return $true
    }
    catch {
        Write-Error "Failed to connect to Docker registry: $_"
        return $false
    }
}

# Export module members
Export-ModuleMember -Function Test-DockerEnvironment, Connect-DockerRegistry 