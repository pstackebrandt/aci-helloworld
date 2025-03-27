# Docker Module Tests

This directory contains tests for the Docker module functionality.

## Test Strategy

### Test Categories

1. **Environment Validation Tests**
   - Valid environment file validation
   - Missing file detection
   - Missing required variables
   - Line ending validation

2. **Docker Login Tests**
   - Dry run mode verification
   - Error handling
   - Failed login scenarios
   - Parameter validation

### Test Structure

```
Tests/
├── Docker.Tests.ps1    # Main test file
└── TestData/           # Temporary test data directory
```

### Test Data Management
- Test data is created in a temporary directory
- Files are cleaned up after tests complete
- Each test context has its own environment file

## Running Tests

### Prerequisites
1. Install Pester module:
```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

2. Ensure Docker is installed and running (for some tests)

### Running Tests

1. **Run all tests with detailed output**:
```powershell
$PesterPreference = [PesterConfiguration]::Default
$PesterPreference.Output.Verbosity = 'Detailed'
$PesterPreference.Run.Path = 'scripts/Modules/Docker/Tests/Docker.Tests.ps1'
Invoke-Pester
```

2. **Run all tests with full error details**:
```powershell
$PesterPreference = [PesterConfiguration]::Default
$PesterPreference.Output.Verbosity = 'Detailed'
$PesterPreference.Debug.ShowFullErrors = $true
$PesterPreference.Run.Path = 'scripts/Modules/Docker/Tests/Docker.Tests.ps1'
Invoke-Pester
```

3. **Run specific test suite**:
```powershell
Invoke-Pester -Path scripts/Modules/Docker/Tests/Docker.Tests.ps1 -TestName "Test-DockerEnvironment"
```

4. **Run with code coverage**:
```powershell
Invoke-Pester -Path scripts/Modules/Docker/Tests/Docker.Tests.ps1 -CodeCoverage scripts/Modules/Docker/Docker.psm1
```

### Test Output
- Detailed test results
- Pass/fail status for each test
- Error messages for failed tests
- Test execution time

## Common Issues and Solutions

1. **Line Ending Issues**
   - Tests expect Unix-style line endings (LF) for shell files
   - The module automatically fixes line endings if needed
   - If you see line ending warnings, they should be resolved automatically

2. **Docker Connection Issues**
   - Some tests mock Docker commands
   - No actual Docker connection is required for most tests
   - Error handling tests simulate connection failures

3. **Module Import Issues**
   - Ensure you're running tests from the project root
   - The module path is relative to the project root
   - Use `-Force` when importing modules to ensure fresh state

4. **Test Data Cleanup**
   - Test data is automatically cleaned up after tests
   - If tests fail, you may need to manually clean up the TestData directory
   - Use `Remove-Item -Recurse -Force scripts/Modules/Docker/Tests/TestData` if needed

## Adding New Tests

1. **Add new test context**:
```powershell
Describe "New Feature" {
    Context "Specific Scenario" {
        It "Should behave as expected" {
            # Test code here
        }
    }
}
```

2. **Add test data**:
```powershell
BeforeEach {
    # Setup test data
}
```

3. **Clean up**:
```powershell
AfterEach {
    # Clean up test data
}
```

## Best Practices

1. **Test Isolation**
   - Each test should be independent
   - Use BeforeEach/AfterEach for setup/cleanup
   - Don't rely on test execution order

2. **Test Data**
   - Use temporary directories
   - Clean up after tests
   - Use realistic test data

3. **Error Cases**
   - Test both success and failure scenarios
   - Include edge cases
   - Test error handling

4. **Documentation**
   - Document test purpose
   - Explain test scenarios
   - Keep test names descriptive 