# =============================================================================
# Azure Service Principal Module
# =============================================================================
# Purpose:
#   Provides functions for managing Azure Service Principals and their credentials,
#   specifically designed for Azure Container Registry (ACR) authentication.
#   This module handles the complete lifecycle of service principal creation,
#   role assignment, and secure credential storage.
#
# Main Functionality:
#   - Creates service principals with New-AzADServicePrincipal
#   - Assigns ACR roles (default: acrpull) via New-AzRoleAssignment
#   - Stores credentials in timestamped .env files (config/secrets/)
#   - Sets restricted file permissions (user-only access)
#   - Automatically adds config/secrets/ to .gitignore
# =============================================================================

# Import required modules
Import-Module $PSScriptRoot\..\FileSystem\GitIgnore.psm1 -Force

function Test-AzureConnection {
    [CmdletBinding()]
    param()

    try {
        $context = Get-AzContext -ErrorAction Stop
        if (-not $context) {
            Write-Host "Connecting to Azure..." -ForegroundColor Yellow
            Connect-AzAccount -ErrorAction Stop | Out-Null
        }
        return $true
    }
    catch {
        Write-Error "Failed to connect to Azure: $_"
        return $false
    }
}

function New-AcrServicePrincipal {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$AcrName,
        
        [Parameter(Mandatory=$true)]
        [string]$ServicePrincipalName,
        
        [Parameter(Mandatory=$false)]
        [string]$Role = "acrpull",
        
        [Parameter(Mandatory=$false)]
        [string]$ResourceGroupName = "myResourceGroup",

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Check Azure connection
    if (-not (Test-AzureConnection)) {
        return $null
    }

    # Get the ACR resource
    try {
        $registry = Get-AzContainerRegistry -Name $AcrName -ResourceGroupName $ResourceGroupName
        
        if (-not $registry) {
            Write-Error "ACR with name '$AcrName' not found"
            return $null
        }
    } 
    catch {
        Write-Error "Failed to get ACR with name '$AcrName': $_"
        return $null
    }

    # Create service principal
    try {
        # Create service principal
        $sp = New-AzADServicePrincipal -DisplayName $ServicePrincipalName
        
        # Get the application ID
        $appId = $sp.AppId
        
        # Assign role to the service principal
        New-AzRoleAssignment -ApplicationId $appId -RoleDefinitionName $Role -Scope $registry.Id

        return @{
            AppId = $appId
            Password = $sp.PasswordCredentials[0].SecretText
            ServicePrincipal = $sp
        }
    }
    catch {
        Write-Error "Failed to create service principal: $_"
        return $null
    }
}

function Save-ServicePrincipalCredentials {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ServicePrincipalInfo,
        
        [Parameter(Mandatory=$true)]
        [string]$AcrName,
        
        [Parameter(Mandatory=$true)]
        [string]$ServicePrincipalName,

        [Parameter(Mandatory=$false)]
        [string]$OutputPath = "config\secrets"
    )

    # Store credentials in a file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $credentialsDir = $OutputPath
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $credentialsDir)) {
        New-Item -Path $credentialsDir -ItemType Directory -Force | Out-Null
    }
    
    $credentialsFile = "$credentialsDir\acr-credentials_$timestamp.env"
    
    @"
# Azure Container Registry Credentials
# Generated on: $(Get-Date)
# For registry: $AcrName
# Service principal: $ServicePrincipalName

ACR_SERVICE_PRINCIPAL_ID=$($ServicePrincipalInfo.AppId)
ACR_SERVICE_PRINCIPAL_PASSWORD=$($ServicePrincipalInfo.Password)
"@ | Out-File -FilePath $credentialsFile -Encoding utf8
    
    # Set restricted permissions
    $acl = Get-Acl $credentialsFile
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$($env:USERNAME)", "FullControl", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $credentialsFile $acl
    
    Write-Host "Credentials stored in: $credentialsFile" -ForegroundColor Green
    Write-Host "Important: Keep this file secure and don't commit it to version control!" -ForegroundColor Yellow
    
    # Update .gitignore if needed
    Update-GitIgnore -Pattern "config/secrets/"
    
    return $credentialsFile
}

# Export module members
Export-ModuleMember -Function New-AcrServicePrincipal, Save-ServicePrincipalCredentials 