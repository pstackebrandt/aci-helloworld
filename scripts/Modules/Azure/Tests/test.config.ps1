# Test Configuration
$global:TestConfig = @{
    # Test environment settings
    TestEnvironment = @{
        AzureMock = $true
        UseTestDrive = $true
    }

    # Module paths
    ModulePaths = @{
        ServicePrincipal = Join-Path $PSScriptRoot "..\ServicePrincipal.psm1"
        GitIgnore = Join-Path $PSScriptRoot "..\..\FileSystem\GitIgnore.psm1"
    }

    # Test settings
    TestSettings = @{
        Output = "Detailed"
        CI = $true
    }
} 