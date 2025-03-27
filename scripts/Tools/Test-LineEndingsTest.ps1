# =============================================================================
# Test Script for Test-LineEndings.ps1
# =============================================================================
# Purpose:
#   Tests the functionality of Test-LineEndings.ps1 by creating test files
#   with incorrect line endings and verifying the fix functionality
#
# Usage:
#   # Run the test script from the Tools directory
#   cd scripts/Tools
#   ./Test-LineEndingsTest.ps1
#
# What the test does:
#   1. Creates a temporary directory 'temp_test_files'
#   2. Creates test files with incorrect line endings:
#      - test.ps1 with Unix endings (should be CRLF)
#      - test.sh with Windows endings (should be LF)
#   3. Runs Test-LineEndings.ps1 in three modes:
#      - Dry run mode to preview changes
#      - Fix mode to correct the line endings
#      - Verification mode to confirm fixes
#   4. Automatically cleans up all test files
#
# Expected Output:
#   - Creation of test files
#   - Warning about incorrect line endings
#   - Confirmation of fixes
#   - Verification that all files are correct
#   - Cleanup confirmation
#
# Note: This test creates and removes files in a temporary directory.
#       No changes are made to your actual project files.
# =============================================================================

# Create temporary test directory
$testDir = Join-Path $PSScriptRoot "temp_test_files"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

try {
    # Create test files with incorrect line endings
    $testFiles = @(
        @{
            Name = "test.ps1"
            Content = "Write-Host 'Hello`nWorld'"  # Unix endings for PS1
            ExpectedEnding = "CRLF"
        },
        @{
            Name = "test.sh"
            Content = "echo 'Hello'`r`necho 'World'"  # Windows endings for SH
            ExpectedEnding = "LF"
        }
    )

    # Create the test files
    foreach ($file in $testFiles) {
        $filePath = Join-Path $testDir $file.Name
        [System.IO.File]::WriteAllText($filePath, $file.Content)
        Write-Host "Created test file: $($file.Name) with incorrect endings"
    }

    # Test dry run mode
    Write-Host "`nTesting Dry Run Mode:" -ForegroundColor Cyan
    Push-Location $testDir
    & "$PSScriptRoot\Test-LineEndings.ps1" -Fix -DryRun
    Pop-Location

    # Test actual fix
    Write-Host "`nTesting Fix Mode:" -ForegroundColor Cyan
    Push-Location $testDir
    & "$PSScriptRoot\Test-LineEndings.ps1" -Fix
    Pop-Location

    # Verify results
    Write-Host "`nVerifying Results:" -ForegroundColor Cyan
    Push-Location $testDir
    & "$PSScriptRoot\Test-LineEndings.ps1"
    Pop-Location

} finally {
    # Cleanup
    if (Test-Path $testDir) {
        Remove-Item -Path $testDir -Recurse -Force
        Write-Host "`nTest files cleaned up successfully" -ForegroundColor Green
    }
} 