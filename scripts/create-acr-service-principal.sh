#!/bin/bash
# =============================================================================
# Azure Container Registry Service Principal Creation Script
# =============================================================================
# Purpose:
#   This script creates a service principal in Azure Active Directory and
#   assigns it permissions to access an Azure Container Registry (ACR).
#   It's useful for setting up non-interactive authentication for applications,
#   CI/CD pipelines, or containers that need to pull images from ACR.
#
# Prerequisites:
#   - Azure CLI version 2.25.0 or later installed (check with `az --version`)
#   - User logged in to Azure CLI with permissions to create service principals
#   - An existing Azure Container Registry
#
# Usage:
#   1. Set the ACR_NAME and SERVICE_PRINCIPAL_NAME environment variables
#   2. Run this script: ./create-service-principal
#   3. Use the output credentials in your application or deployment scripts
#
# For more details, see the accompanying documentation in docs/acr-auth.md
# =============================================================================

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_NAME=$servicePrincipal

# Obtain the full registry ID for the ACR instance
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
# echo $registryId

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only (least privilege, recommended for most scenarios)
# acrpush:     push and pull (use for CI/CD pipelines that build and push images)
# owner:       push, pull, and assign roles (use with caution, grants admin rights)
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"

# Note: Store these credentials securely. Consider using Azure Key Vault
# or environment variables depending on your deployment scenario. 