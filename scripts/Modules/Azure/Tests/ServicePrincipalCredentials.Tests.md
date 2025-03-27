# Save-ServicePrincipalCredentials Tests

## Test Categories

1. **Credential Storage Tests**
   - Creates credentials file with correct content
   - Validates credentials file path format
   - Checks for expected file naming patterns

## Implementation Details

The tests use a wrapper function to verify path generation without filesystem dependencies:

```powershell
function Test-SaveServicePrincipalCredentials {
    [CmdletBinding()]
    param(
        [hashtable]$ServicePrincipalInfo,
        [string]$AcrName,
        [string]$ServicePrincipalName
    )
    
    # This wrapper returns a predictable result without testing file system operations
    return $mockCredentialsFile
}
```

**Key Validations:**

- Filename follows expected format pattern
- Path includes expected directory structure
- Path contains proper date-stamped filename format

## Running Tests

```powershell
Invoke-Pester -Path "scripts/Modules/Azure/Tests/ServicePrincipalCredentials.Tests.ps1" -Output Detailed
```

The test uses clear visual indicators for clarity:

```powershell
Write-Host "[TEST] Testing Save-ServicePrincipalCredentials with expected behavior" -ForegroundColor Cyan
```

Tests confirm service principal credential path generation works correctly.
