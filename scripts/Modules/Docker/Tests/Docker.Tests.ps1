# =============================================================================
# Docker Module Tests
# =============================================================================
# Purpose:
#   Tests for the Docker module functions, including environment validation
#   and registry connection functionality.
# =============================================================================

BeforeAll {
    # Import the Docker module
    $modulePath = Join-Path $PSScriptRoot "..\Docker.psm1"
    Write-Host "Loading module from: $modulePath"
    Import-Module $modulePath -ErrorAction Stop

    # Import LineEndings module for test file setup
    $lineEndingsModule = Join-Path $PSScriptRoot "..\LineEndings\LineEndings.psm1"
    Import-Module $lineEndingsModule -Force

    # Create test directory
    $testDir = Join-Path $PSScriptRoot "TestData"
    if (Test-Path $testDir) {
        Remove-Item $testDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $testDir | Out-Null

    # Function to create test file with LF endings
    function New-TestFile {
        param(
            [string]$Path,
            [string]$Content
        )
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($Path, $Content.Replace("`r`n", "`n"), $utf8NoBom)
    }
}

Describe "Test-DockerEnvironment" {
    Context "Valid environment file" {
        BeforeEach {
            $envFile = Join-Path $testDir "valid-env.sh"
            New-TestFile -Path $envFile -Content @'
export containerRegistry="testregistry"
export servicePrincipal="testsp"
export password="testpass"
'@
        }

        It "Should validate a correct environment file" {
            Test-DockerEnvironment -EnvFile $envFile | Should -Be $true
        }
    }

    Context "Invalid environment file" {
        BeforeEach {
            $envFile = Join-Path $testDir "invalid-env.sh"
            New-TestFile -Path $envFile -Content @'
export containerRegistry="testregistry"
export servicePrincipal="testsp"
'@
        }

        It "Should detect missing required variables" {
            Test-DockerEnvironment -EnvFile $envFile | Should -Be $false
        }
    }
}

Describe "Connect-DockerRegistry" {
    Context "Dry run mode" {
        BeforeEach {
            $envFile = Join-Path $testDir "dry-run-env.sh"
            New-TestFile -Path $envFile -Content @'
export containerRegistry="testregistry"
export servicePrincipal="testsp"
export password="testpass"
'@
        }

        It "Should not execute actual login in dry run mode" {
            Connect-DockerRegistry -EnvFile $envFile -DryRun | Should -Be $true
        }
    }

    Context "Error handling" {
        BeforeEach {
            $envFile = Join-Path $testDir "error-env.sh"
            New-TestFile -Path $envFile -Content @'
export containerRegistry="testregistry"
export servicePrincipal="testsp"
export password="testpass"
'@
            # Mock Invoke-Expression to simulate docker login failure
            Mock -CommandName Invoke-Expression -MockWith { throw "Login failed" } -ModuleName Docker
        }

        It "Should handle login failures gracefully" {
            Connect-DockerRegistry -EnvFile $envFile | Should -Be $false
        }
    }
}

AfterAll {
    # Cleanup test directory
    if (Test-Path $testDir) {
        Remove-Item $testDir -Recurse -Force
    }
} 