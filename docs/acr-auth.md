# Azure Container Registry Authentication Guide

## Table of Contents

- [Azure Container Registry Authentication Guide](#azure-container-registry-authentication-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Purpose](#purpose)
  - [Prerequisites](#prerequisites)
  - [Script Usage](#script-usage)
    - [Step 1: Set Environment Variables](#step-1-set-environment-variables)
    - [Step 2: Run the Script](#step-2-run-the-script)
    - [Step 3: Store the Credentials](#step-3-store-the-credentials)
  - [Access Control Options](#access-control-options)
  - [Using the Service Principal](#using-the-service-principal)
    - [Docker Login](#docker-login)
    - [Kubernetes Secrets](#kubernetes-secrets)
    - [Azure Container Instances](#azure-container-instances)
  - [Application Deployment](#application-deployment)
  - [Security Considerations](#security-considerations)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
    - [Helpful Commands](#helpful-commands)
  - [Additional Resources](#additional-resources)

## Overview

This document provides detailed information about the `create-acr-service-principal.sh` script and how to use it to set up authentication for Azure Container Registry (ACR).

## Purpose

The script creates an Azure Active Directory (AAD) service principal and grants it access to pull images from an Azure Container Registry. Service principals provide a secure way for applications, services, and automation tools to authenticate with Azure resources without using user credentials.

## Prerequisites

Before using the script, ensure you have:

- Azure CLI version 2.25.0 or later installed
- An active Azure subscription
- An existing Azure Container Registry
- Permissions to create service principals in your Azure Active Directory tenant
- Bash shell environment (WSL, Linux, macOS, or Git Bash on Windows)

## Script Usage

### Step 1: Set Environment Variables

Before running the script, set the required environment variables:

```bash
export containerRegistry="your-acr-name"
export servicePrincipal="acr-service-principal"
```

### Step 2: Run the Script

Make the script executable (if needed) and run it:

```bash
chmod +x scripts/create-acr-service-principal.sh
./scripts/create-acr-service-principal.sh
```

### Step 3: Store the Credentials

The script outputs two pieces of information:

- Service principal ID (username/appId)
- Service principal password

Store these credentials securely. Options include:

- Azure Key Vault
- GitHub Secrets (for GitHub Actions)
- Azure DevOps variable groups
- Environment variables in your deployment environment

## Access Control Options

The script supports three levels of access to your container registry:

| Role      | Permissions                             | Use Case                                   |
| --------- | --------------------------------------- | ------------------------------------------ |
| `acrpull` | Pull images only                        | Production applications, read-only access  |
| `acrpush` | Pull and push images                    | CI/CD pipelines, build servers             |
| `owner`   | Full control, including role assignment | Administrative purposes (use with caution) |

To modify the access level, edit the `--role` parameter in the script.

## Using the Service Principal

### Docker Login

```bash
docker login <your-registry-name>.azurecr.io --username <service-principal-id> --password <service-principal-password>
```

### Kubernetes Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: acr-auth
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

### Azure Container Instances

```bash
az container create \
  --resource-group myResourceGroup \
  --name mycontainer \
  --image <acr-name>.azurecr.io/myimage:latest \
  --registry-username <service-principal-id> \
  --registry-password <service-principal-password> \
  --dns-name-label mydnsname \
  --ports 80
```

## Application Deployment

This project includes a simple Node.js Express application that can be deployed to Azure Container Instances. The application is containerized using Node.js 20 and includes:

- Express.js web server
- Morgan logging middleware
- Simple HTML interface

To deploy the application after setting up authentication:

1. Build the container:

   ```bash
   docker build -t <your-registry>.azurecr.io/aci-helloworld:latest .
   ```

2. Push to your registry:

   ```bash
   docker push <your-registry>.azurecr.io/aci-helloworld:latest
   ```

3. Deploy to ACI:

   ```bash
   az container create \
     --resource-group myResourceGroup \
     --name aci-helloworld \
     --image <your-registry>.azurecr.io/aci-helloworld:latest \
     --registry-username <service-principal-id> \
     --registry-password <service-principal-password> \
     --dns-name-label aci-helloworld \
     --ports 80
   ```

## Security Considerations

- Rotate service principal credentials periodically (recommended every 90 days)
- Use the principle of least privilege (use `acrpull` when possible)
- Consider using managed identities for Azure resources instead of service principals when applicable
- Never hardcode credentials in source code or configuration files

## Troubleshooting

### Common Issues

1. **Authentication failure**: Verify the service principal still exists and has the correct permissions.

2. **"Insufficient privileges"**: Ensure the service principal has the appropriate role assigned.

3. **Script errors**: Make sure you're logged in to Azure CLI with `az login` before running the script.

4. **Node.js version compatibility**: The application now uses Node.js 20. If you encounter issues, check your Node.js version compatibility.

### Helpful Commands

Check if your service principal exists:

```bash
az ad sp list --display-name <service-principal-name>
```

Verify role assignments:

```bash
az role assignment list --assignee <service-principal-id> --scope <acr-registry-id>
```

## Additional Resources

- [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Service principals with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [ACR authentication options](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication)
- [Azure Container Instances documentation](https://docs.microsoft.com/en-us/azure/container-instances/)
