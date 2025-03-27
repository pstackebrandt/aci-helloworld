# ServicePrincipal Module Tests

## Status Update: All Recommendations Implemented

The issues and observations in this document have been addressed by implementing separate test files for specific functionality:

1. **NewAcrServicePrincipal.Tests.ps1** - For service principal creation and role assignment
2. **ServicePrincipalCredentials.Tests.ps1** - For credential storage functionality

## Previous Test Issues and Observations

### 1. Azure Authentication Issues

- The tests repeatedly prompt for Azure account selection ✅ (RESOLVED through mocking)
- The prompt "Please select the account you want to login with" appears multiple times ✅ (RESOLVED)
- No way to provide input during test execution ✅ (RESOLVED)
- This indicates the Azure authentication mocking is not working correctly ✅ (RESOLVED)

### 2. Module Dependencies

- The module requires several Azure modules: ✅ (RESOLVED through mocking)
  - Az.Accounts
  - Az.Resources
  - Az.ContainerRegistry
- These dependencies are now properly mocked ✅ (RESOLVED)

### 3. Test Structure Issues

- Tests are trying to run in parallel ✅ (RESOLVED with proper scoping)
- This issue has been addressed with proper test isolation ✅ (RESOLVED)

### 4. Mocking Challenges

- Azure cmdlets are now properly mocked ✅ (RESOLVED)
- The module's internal functions are properly isolated ✅ (RESOLVED)
- File system operations now use a wrapper approach ✅ (RESOLVED)

## Current Implementation

### 1. Test Configuration

A global test configuration has been implemented in `test.config.ps1`:

```powershell
$global:TestConfig = @{
    TestEnvironment = @{
        AzureMock = $true
        UseTestDrive = $true
    }
    # Other configuration settings...
}
```

### 2. Test Runner

A test runner script `Run-Tests.ps1` now executes all tests and provides a summary:

```powershell
# Run the tests for New-AcrServicePrincipal
$testResults1 = Invoke-Pester -Path "$PSScriptRoot\NewAcrServicePrincipal.Tests.ps1" -Output $outputFormat -PassThru
    
# Run the tests for Save-ServicePrincipalCredentials
$testResults2 = Invoke-Pester -Path "$PSScriptRoot\ServicePrincipalCredentials.Tests.ps1" -Output $outputFormat -PassThru
```

### 3. Specific Test Files

Each major functionality now has its own test file and documentation:

- `NewAcrServicePrincipal.Tests.ps1` and `NewAcrServicePrincipal.Tests.md`
- `ServicePrincipalCredentials.Tests.ps1` and `ServicePrincipalCredentials.Tests.md`

## Recommended Usage

For running all tests:

```powershell
.\scripts\Modules\Azure\Tests\Run-Tests.ps1
```

For running specific test files:

```powershell
Invoke-Pester -Path "scripts/Modules/Azure/Tests/NewAcrServicePrincipal.Tests.ps1" -Output Detailed
Invoke-Pester -Path "scripts/Modules/Azure/Tests/ServicePrincipalCredentials.Tests.ps1" -Output Detailed
```

## Working Test Cases

### 1. Service Principal Creation

```powershell
It "Creates service principal with default role" {
    $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp"
    $result.AppId | Should -Be "test-app-id"
    $result.Password | Should -Be "test-password"
}
```

### 2. Role Assignment

```powershell
It "Creates service principal with custom role" {
    $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp" -Role "acrpush"
    Assert-MockCalled -CommandName New-AzRoleAssignment -ModuleName ServicePrincipal -ParameterFilter {
        $RoleDefinitionName -eq "acrpush"
    }
}
```

### 3. Error Handling

```powershell
It "Handles missing ACR" {
    Mock -CommandName Get-AzContainerRegistry -ModuleName ServicePrincipal { return $null }
    $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp"
    $result | Should -Be $null
}
```
