# Configuration Validation Script
# This script validates the ACR environment configuration files
#
# Usage:
#   # Basic validation
#   .\Validate-Config.ps1
#
#   # Strict validation (treats warnings as errors)
#   .\Validate-Config.ps1 -Strict
#
# Features:
#   - Validates required environment variables
#   - Checks file permissions
#   - Detects potential sensitive data
#   - Validates line endings (LF for .sh files)
#   - Validates variable values
#   - Supports strict mode for CI/CD

param(
    [Parameter(Mandatory=$false)]
    [switch]$Strict
)

# Configuration
$ConfigFiles = @{
    "config/acr-env-template.sh" = @{
        Required = @{
            "containerRegistry" = "^[a-z0-9]+$"  # Lowercase alphanumeric
            "servicePrincipal" = "^[a-zA-Z0-9-]+$"  # Alphanumeric with hyphens
        }
        Optional = @{
            "ACR_ROLE" = "^(AcrPull|AcrPush|Owner)$"  # Valid ACR roles
        }
        Permissions = "644"  # rw-r--r--
        IsTemplate = $true
    }
    "config/acr-env.sh" = @{
        Required = @{
            "containerRegistry" = "^[a-z0-9]+$"
            "servicePrincipal" = "^[a-zA-Z0-9-]+$"
        }
        Optional = @{
            "ACR_ROLE" = "^(AcrPull|AcrPush|Owner)$"
        }
        Permissions = "600"  # rw-------
        IsTemplate = $false
    }
}

# Function to check line endings
function Test-LineEndings {
    param(
        [string]$FilePath
    )
    
    if (Test-Path $FilePath) {
        $content = Get-Content -Raw $FilePath
        if ($content -match "`r`n") {
            Write-Host "Warning: File ${FilePath} contains CRLF line endings" -ForegroundColor Yellow
            Write-Host "Expected: LF (Unix) line endings for shell scripts" -ForegroundColor Yellow
            return $false
        }
        return $true
    }
    return $false
}

# Function to validate file permissions
function Test-FilePermissions {
    param(
        [string]$FilePath,
        [string]$ExpectedPermissions
    )

    if (Test-Path $FilePath) {
        # Get file attributes
        $fileInfo = Get-Item $FilePath
        $isReadOnly = $fileInfo.IsReadOnly
        
        # Check if file is readable by all (644) or owner only (600)
        if ($ExpectedPermissions -eq "644" -and $isReadOnly) {
            Write-Host "Warning: File permissions for ${FilePath} are incorrect" -ForegroundColor Yellow
            Write-Host "Expected: Readable by all (644)" -ForegroundColor Yellow
            Write-Host "Actual: Read-only" -ForegroundColor Yellow
            return $false
        }
        return $true
    }
    if (-not $ConfigFiles[$FilePath].IsTemplate) {
        Write-Host "Info: Optional file ${FilePath} not found (this is normal for environment-specific files)" -ForegroundColor Blue
        return $true
    }
    Write-Host "Error: Required file ${FilePath} not found" -ForegroundColor Red
    return $false
}

# Function to validate variable values
function Test-VariableValue {
    param(
        [string]$Value,
        [string]$Pattern,
        [string]$VarName
    )

    if ($Value -notmatch $Pattern) {
        Write-Host "  - Invalid value for ${VarName}: '${Value}'" -ForegroundColor Red
        Write-Host "    Expected pattern: ${Pattern}" -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Function to validate environment variables
function Test-EnvironmentVariables {
    param(
        [string]$FilePath,
        [hashtable]$Required,
        [hashtable]$Optional,
        [bool]$Strict,
        [bool]$IsTemplate
    )

    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $missing = @()
        $invalid = @()
        $invalidValues = @()

        # Check required variables
        foreach ($var in $Required.Keys) {
            $pattern = "export\s+$var\s*=\s*[`"']?([^`"']*)[`"']?"
            if ($content -notmatch $pattern) {
                $missing += $var
            } else {
                $value = $matches[1]
                if (-not $IsTemplate -and -not (Test-VariableValue -Value $value -Pattern $Required[$var] -VarName $var)) {
                    $invalidValues += $var
                }
            }
        }

        # Check optional variables if present
        foreach ($var in $Optional.Keys) {
            $pattern = "export\s+$var\s*=\s*[`"']?([^`"']*)[`"']?"
            if ($content -match $pattern) {
                $value = $matches[1]
                if (-not $IsTemplate -and -not (Test-VariableValue -Value $value -Pattern $Optional[$var] -VarName $var)) {
                    $invalidValues += $var
                }
            }
        }

        # Check for sensitive data in non-template files
        if (-not $IsTemplate) {
            if ($content -match "your-|password|secret|key|token") {
                $invalid += "Potential sensitive data found"
            }
        }

        # Report results
        if ($missing.Count -gt 0) {
            Write-Host "Error: Missing required variables in ${FilePath}:" -ForegroundColor Red
            $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
            return $false
        }

        if ($invalidValues.Count -gt 0) {
            Write-Host "Error: Invalid variable values in ${FilePath}:" -ForegroundColor Red
            return $false
        }

        if ($invalid.Count -gt 0) {
            Write-Host "Warning: Invalid content found in ${FilePath}:" -ForegroundColor Yellow
            $invalid | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
            if ($Strict) { return $false }
        }

        return $true
    }
    if (-not $IsTemplate) {
        Write-Host "Info: Optional file ${FilePath} not found (this is normal for environment-specific files)" -ForegroundColor Blue
        return $true
    }
    Write-Host "Error: Required file ${FilePath} not found" -ForegroundColor Red
    return $false
}

# Main execution
Write-Host "`nConfiguration Validation" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

$allValid = $true
foreach ($file in $ConfigFiles.GetEnumerator()) {
    Write-Host "`nValidating $($file.Key)..." -ForegroundColor Cyan

    # Check if file exists
    if (Test-Path $file.Key) {
        # Check line endings
        Write-Host "Checking line endings..." -ForegroundColor Gray
        $lineEndingsValid = Test-LineEndings -FilePath $file.Key
        if (-not $lineEndingsValid) { $allValid = $false }

        # Check file permissions
        Write-Host "Checking file permissions..." -ForegroundColor Gray
        $permissionsValid = Test-FilePermissions -FilePath $file.Key -ExpectedPermissions $file.Value.Permissions
        if (-not $permissionsValid) { $allValid = $false }

        # Check environment variables
        Write-Host "Checking environment variables..." -ForegroundColor Gray
        $variablesValid = Test-EnvironmentVariables `
            -FilePath $file.Key `
            -Required $file.Value.Required `
            -Optional $file.Value.Optional `
            -Strict $Strict `
            -IsTemplate $file.Value.IsTemplate
        if (-not $variablesValid) { $allValid = $false }
    } else {
        # Handle missing files
        if ($file.Value.IsTemplate) {
            Write-Host "Error: Required template file $($file.Key) not found" -ForegroundColor Red
            $allValid = $false
        } else {
            Write-Host "Info: Optional file $($file.Key) not found (this is normal)" -ForegroundColor Blue
        }
    }
}

Write-Host "`nValidation Summary:" -ForegroundColor Cyan
if ($allValid) {
    Write-Host "All configurations are valid!" -ForegroundColor Green
} else {
    Write-Host "Configuration validation failed. Please check the warnings above." -ForegroundColor Red
    exit 1
} 