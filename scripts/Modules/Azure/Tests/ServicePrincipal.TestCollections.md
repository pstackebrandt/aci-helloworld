# ServicePrincipal Module Tests

This document describes the test structure for the ServicePrincipal module.

## Test Organization

The tests are organized into logical collections that cover different aspects of the ServicePrincipal module functionality:

| Collection            | Status       | Test File                               | Documentation                          |
| --------------------- | ------------ | --------------------------------------- | -------------------------------------- |
| 1. Basic Operations   | ✅ Working    | `NewAcrServicePrincipal.Tests.ps1`      | `NewAcrServicePrincipal.Tests.md`      |
| 2. Credential Storage | ✅ Working    | `ServicePrincipalCredentials.Tests.ps1` | `ServicePrincipalCredentials.Tests.md` |
| 3. Azure Integration  | 🔵 Not Needed | N/A                                     | N/A                                    |
| 4. Error Scenarios    | ✅ Working    | Integrated into Collections 1 & 2       | See respective docs                    |

## Test Infrastructure

### Configuration

Global test configuration in `test.config.ps1`:

```powershell
$global:TestConfig = @{
    TestEnvironment = @{
        AzureMock = $true
        UseTestDrive = $true
    }
    ModulePaths = { ... }
    TestSettings = { ... }
}
```

### Test Runner

Central test runner in `Run-Tests.ps1`:

- Runs all test files
- Aggregates test results
- Provides summary statistics

## Collection Details

### Collection 1: Basic Service Principal Operations

These tests verify core functionality for creating service principals and assigning roles.

**Implementation:**

- Uses mocked Azure cmdlets
- Tests default and custom role assignments
- Implements error handling tests
- Uses visual indicators for expected failures

**Key Tests:**

- Service principal creation with default role
- Custom role assignment
- Graceful handling of missing ACR
- Service principal creation failure handling

### Collection 2: Credential Storage

These tests verify the credential file storage functionality.

**Implementation:**

- Uses wrapper functions to avoid filesystem dependencies
- Verifies path format and file naming
- Uses consistent test output formatting
- Integrates with global test configuration

**Key Tests:**

- Credential file path generation
- Directory structure validation
- Filename format verification
- Shows configuration during test execution

## Best Practices Implemented

1. **Visual Test Indicators**

   ```powershell
   Write-Host "[TEST] Expected failure: ACR 'testacr' not found" -ForegroundColor Cyan
   ```

2. **Wrapper Function Approach**

   ```powershell
   function Test-SaveServicePrincipalCredentials {
       # Implementation that avoids actual filesystem operations
   }
   ```

3. **Global Configuration**

   ```powershell
   if ($global:TestConfig.TestEnvironment.AzureMock) {
       Write-Host "[CONFIG] Using Azure mock mode: $($global:TestConfig.TestEnvironment.AzureMock)"
   }
   ```

4. **Comprehensive Mocking**

   ```powershell
   Mock -CommandName Get-AzContainerRegistry -MockWith { return $null } -ModuleName ServicePrincipal
   ```
