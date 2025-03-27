# Test runner for ServicePrincipal module
# This script runs the tests in the correct order and environment

# Import test configuration
. "$PSScriptRoot\test.config.ps1"

# Function to verify module loading
function Test-ModuleLoaded {
    param (
        [string]$ModuleName
    )
    
    $module = Get-Module -Name $ModuleName
    if (-not $module) {
        Write-Error "Module $ModuleName not loaded"
        return $false
    }
    return $true
}

# Import ServicePrincipal module
Write-Host "Importing ServicePrincipal module..."
Import-Module "$PSScriptRoot\..\ServicePrincipal.psm1" -Force
if (-not (Test-ModuleLoaded -ModuleName "ServicePrincipal")) {
    Write-Error "Failed to load ServicePrincipal module"
    exit 1
}

# Run tests
Write-Host "`nRunning tests..."
try {
    # Configure Pester output from config
    $outputFormat = $global:TestConfig.TestSettings.Output

    # Run the tests for New-AcrServicePrincipal
    Write-Host "`nRunning New-AcrServicePrincipal tests..."
    $testResults1 = Invoke-Pester -Path "$PSScriptRoot\NewAcrServicePrincipal.Tests.ps1" -Output $outputFormat -PassThru
    
    # Run the tests for Save-ServicePrincipalCredentials
    Write-Host "`nRunning Save-ServicePrincipalCredentials tests..."
    $testResults2 = Invoke-Pester -Path "$PSScriptRoot\ServicePrincipalCredentials.Tests.ps1" -Output $outputFormat -PassThru
    
    # Combine results
    $totalCount = $testResults1.TotalCount + $testResults2.TotalCount
    $passedCount = $testResults1.PassedCount + $testResults2.PassedCount
    $failedCount = $testResults1.FailedCount + $testResults2.FailedCount
    $skippedCount = $testResults1.SkippedCount + $testResults2.SkippedCount
    
    $testSuccess = ($failedCount -eq 0)
} catch {
    Write-Error "Test execution failed: $_"
    $testSuccess = $false
}

# Output results
Write-Host "`nTest Results:"
Write-Host "-------------"
Write-Host "Total Tests: $totalCount"
Write-Host "Passed: $passedCount"
Write-Host "Failed: $failedCount"
Write-Host "Skipped: $skippedCount"

# Exit with appropriate code
exit $(if ($testSuccess) { 0 } else { 1 }) 