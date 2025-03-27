# New-AcrServicePrincipal Tests

## Test Categories

1. **Success Tests**
   - Creates service principal with default role (`acrpull`)
   - Creates service principal with custom role (`acrpush`)

2. **Error Handling Tests**
   - Handles missing ACR
   - Handles service principal creation failure

## Error Handling Implementation

The error handling tests use clear visual indicators for expected failures:

```powershell
Mock -CommandName Get-AzContainerRegistry -MockWith { 
    Write-Host "[TEST] Expected failure: ACR 'testacr' not found - this is part of the test" -ForegroundColor Cyan
    return $null 
} -ModuleName ServicePrincipal
```

**Features:**

- **Cyan Messages**: Distinguishes test messages from actual errors
- **[TEST] Prefix**: Clearly identifies test-generated messages
- **"Expected failure"**: Explicitly notes intended failures
- **Verification**: Confirms function was called and returned null

## Running Tests

```powershell
Invoke-Pester -Path "scripts/Modules/Azure/Tests/NewAcrServicePrincipal.Tests.ps1" -Output Detailed
```

Error handling tests are confirmed working properly.
