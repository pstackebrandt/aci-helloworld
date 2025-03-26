# =============================================================================
# Azure Container Registry Service Principal Creation Script (PowerShell)
# =============================================================================
# Purpose:
#   This script creates a service principal in Azure Active Directory and
#   assigns it permissions to access an Azure Container Registry (ACR).
#   It reads configuration from the acr-env.sh file to maintain consistency
#   with the bash scripts.
#
# Prerequisites:
#   - Az PowerShell module installed
#   - User logged in to Azure with Connect-AzAccount
#   - An existing Azure Container Registry
#
# Usage:
#   .\scripts\Create-AzAcrServicePrincipal.ps1
# =============================================================================

# Read environment variables from acr-env.sh
$envFilePath = "config/acr-env.sh"
if (-not (Test-Path $envFilePath)) {
    Write-Error "Environment file $envFilePath not found. Please create it from the template."
    exit 1
}

# Parse the acr-env.sh file to extract variables
$envContent = Get-Content $envFilePath -Raw
$acrName = if ($envContent -match 'export containerRegistry="([^"]+)"') { $matches[1] } else { $null }
$servicePrincipalName = if ($envContent -match 'export servicePrincipal="([^"]+)"') { $matches[1] } else { $null }
$acrRole = if ($envContent -match 'export ACR_ROLE="([^"]+)"') { $matches[1] } else { "acrpull" }

# Validate parsed values
if (-not $acrName -or -not $servicePrincipalName) {
    Write-Error "Failed to parse required variables from $envFilePath"
    exit 1
}

Write-Host "Creating service principal for ACR: $acrName" -ForegroundColor Cyan
Write-Host "Service Principal Name: $servicePrincipalName" -ForegroundColor Cyan
Write-Host "Role: $acrRole" -ForegroundColor Cyan

# Connect to Azure if not already connected
try {
    $context = Get-AzContext
    if (-not $context) {
        Connect-AzAccount
    }
} 
catch {
    Write-Host "Connecting to Azure..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Get the ACR resource
try {
    $registry = Get-AzContainerRegistry -Name $acrName -ResourceGroupName "myResourceGroup"
    
    if (-not $registry) {
        Write-Error "ACR with name '$acrName' not found"
        exit 1
    }
} 
catch {
    Write-Error "Failed to get ACR with name '$acrName': $_"
    exit 1
}

# Create service principal
try {
    # Generate a strong password
    # TODO fix this
    $password = [System.Guid]::NewGuid().ToString() + [System.Guid]::NewGuid().ToString()
    
    # Create service principal
    $sp = New-AzADServicePrincipal -DisplayName $servicePrincipalName
    
    # Get the application ID
    $appId = $sp.AppId
    
    # Assign role to the service principal
    New-AzRoleAssignment -ApplicationId $appId -RoleDefinitionName $acrRole -Scope $registry.Id

    # Output the credentials
    Write-Host "Service principal ID: $appId" -ForegroundColor Green
    Write-Host "Service principal password: $($sp.PasswordCredentials[0].SecretText)" -ForegroundColor Green
    
    # Store credentials in a file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $credentialsDir = "config\secrets"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $credentialsDir)) {
        New-Item -Path $credentialsDir -ItemType Directory -Force | Out-Null
    }
    
    $credentialsFile = "$credentialsDir\acr-credentials_$timestamp.env"
    
    @"
# Azure Container Registry Credentials
# Generated on: $(Get-Date)
# For registry: $acrName
# Service principal: $servicePrincipalName

ACR_SERVICE_PRINCIPAL_ID=$appId
ACR_SERVICE_PRINCIPAL_PASSWORD=$($sp.PasswordCredentials[0].SecretText)
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
    $gitignorePath = ".gitignore"
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath -Raw
        if (-not ($gitignoreContent -match "config/secrets/")) {
            Add-Content -Path $gitignorePath -Value "config/secrets/"
            Write-Host "Added config/secrets/ to .gitignore" -ForegroundColor Green
        }
    } else {
        "config/secrets/" | Out-File -FilePath $gitignorePath -Encoding utf8
        Write-Host "Created .gitignore with config/secrets/" -ForegroundColor Green
    }
} 
catch {
    Write-Error "Failed to create service principal: $_"
    exit 1
}

Write-Host "Service principal created successfully!" -ForegroundColor Green
Write-Host "You can now use Docker to log in with these credentials." -ForegroundColor Yellow 