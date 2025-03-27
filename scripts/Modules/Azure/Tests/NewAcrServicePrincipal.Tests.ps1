# =============================================================================
# New-AcrServicePrincipal Module Tests
# =============================================================================
# Purpose:
#   Tests for the New-AcrServicePrincipal function
# =============================================================================

BeforeAll {
    # Import required modules
    Import-Module $PSScriptRoot\..\ServicePrincipal.psm1 -Force

    # Mock Azure cmdlets with -ModuleName parameter
    Mock -CommandName Connect-AzAccount -MockWith { } -ModuleName ServicePrincipal
    Mock -CommandName Get-AzContext -MockWith { 
        return @{ Account = "test" } 
    } -ModuleName ServicePrincipal
    Mock -CommandName Get-AzContainerRegistry -MockWith { 
        return @{
            Id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.ContainerRegistry/registries/testacr"
            Name = "testacr"
        }
    } -ModuleName ServicePrincipal
    Mock -CommandName New-AzADServicePrincipal -MockWith {
        return @{
            AppId = "test-app-id"
            PasswordCredentials = @(
                @{ SecretText = "test-password" }
            )
        }
    } -ModuleName ServicePrincipal
    Mock -CommandName New-AzRoleAssignment -MockWith { return $true } -ModuleName ServicePrincipal
}

Describe "New-AcrServicePrincipal" {
    Context "When all Azure operations succeed" {
        It "Creates service principal with default role" {
            $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp"
            
            Should -Invoke Get-AzContainerRegistry -Times 1 -ParameterFilter {
                $Name -eq "testacr"
            } -ModuleName ServicePrincipal
            
            Should -Invoke New-AzADServicePrincipal -Times 1 -ParameterFilter {
                $DisplayName -eq "testsp"
            } -ModuleName ServicePrincipal
            
            Should -Invoke New-AzRoleAssignment -Times 1 -ParameterFilter {
                $RoleDefinitionName -eq "acrpull"
            } -ModuleName ServicePrincipal
            
            $result.AppId | Should -Be "test-app-id"
            $result.Password | Should -Be "test-password"
        }

        It "Uses custom role when specified" {
            $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp" -Role "acrpush"
            
            Should -Invoke New-AzRoleAssignment -Times 1 -ParameterFilter {
                $RoleDefinitionName -eq "acrpush"
            } -ModuleName ServicePrincipal
            
            $result.AppId | Should -Be "test-app-id"
            $result.Password | Should -Be "test-password"
        }
    }

    Context "When Azure operations fail" {
        It "Handles missing ACR gracefully" {
            Mock -CommandName Get-AzContainerRegistry -MockWith { 
                Write-Host "[TEST] Expected failure: ACR 'testacr' not found - this is part of the test" -ForegroundColor Cyan
                return $null 
            } -ModuleName ServicePrincipal
            
            $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp"
            $result | Should -Be $null
            Should -Invoke Get-AzContainerRegistry -Times 1 -ModuleName ServicePrincipal
        }

        It "Handles service principal creation failure" {
            Mock -CommandName New-AzADServicePrincipal -MockWith { 
                Write-Host "[TEST] Expected failure: Unable to create service principal 'testsp' - this is part of the test" -ForegroundColor Cyan
                throw "Failed to create SP: Insufficient permissions or service principal name already exists"
            } -ModuleName ServicePrincipal
            
            $result = New-AcrServicePrincipal -AcrName "testacr" -ServicePrincipalName "testsp"
            $result | Should -Be $null
            Should -Invoke New-AzADServicePrincipal -Times 1 -ModuleName ServicePrincipal
        }
    }
} 