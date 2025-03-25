# Azure Container Registry Authentication Setup Guide

## Overview

This guide explains how to use the scripts in this project to set up authentication for Azure Container Registry (ACR). The scripts provide a consistent, secure way to create and manage service principals for ACR access.

## Prerequisites

- Windows 11 with either:
  - WSL2 (Ubuntu) installed
  - Git Bash installed
- Azure CLI installed and logged in
- Docker installed (for using the credentials)
- An existing Azure Container Registry

## Quick Start for Windows Users

1. Open PowerShell in the project root directory
2. Run the setup script:

   ```powershell
   .\scripts\Run-AcrSetup.ps1
   ```

3. Follow the prompts to enter your ACR name and service principal name
4. The script will create the service principal and store the credentials securely
5. To log in to Docker with the credentials:

   ```powershell
   .\scripts\Run-DockerLogin.ps1
   ```

6. You can now build and push your container:

   ```powershell
   docker build -t <your-registry>.azurecr.io/aci-helloworld .
   docker push <your-registry>.azurecr.io/aci-helloworld
   ```

## Manual Setup Process

If you prefer to run the individual scripts manually, you can use the following process:

### 1. Set Up Configuration

Copy the template and fill in your values:

```bash
# In WSL or Git Bash
cp config/acr-env-template.sh config/acr-env.sh
nano config/acr-env.sh  # Edit the file with your values
```

### 2. Run the Setup Script

This will create the service principal and store the credentials:

```bash
# In WSL or Git Bash
./scripts/setup-acr-auth.sh
```

### 3. Log In to Docker

Use the credentials to log in to Docker:

```bash
# In WSL or Git Bash
./scripts/docker-login-acr.sh
```

## Project Structure

- `config/`
  - `acr-env-template.sh` - Template for environment variables
  - `acr-env.sh` - Your specific environment variables (created from template)
  - `secrets/` - Directory where credentials are stored
- `scripts/`
  - `create-acr-service-principal.sh` - Creates the service principal
  - `store-acr-credentials.sh` - Securely stores the credentials
  - `setup-acr-auth.sh` - Wrapper script for the entire process
  - `docker-login-acr.sh` - Uses the credentials to log in to Docker
  - `Run-AcrSetup.ps1` - PowerShell wrapper for the setup process
  - `Run-DockerLogin.ps1` - PowerShell wrapper for Docker login
- `app/` - Node.js application (Express)
- `Dockerfile` - Container definition using Node.js 20

## Security Considerations

- All credentials are stored in the `config/secrets/` directory
- This directory is excluded from git via `.gitignore`
- Credentials are stored with timestamp in the filename for versioning
- File permissions are set to 600 (read/write for owner only) in Linux environments
- Regular credential rotation is recommended (every 90 days)

## Troubleshooting

### Common Issues

1. **Script execution errors**: Make sure scripts have execute permissions in WSL:

   ```bash
   chmod +x scripts/*.sh
   ```

2. **"Authentication failed"**: Verify your Azure CLI is logged in:

   ```bash
   az login
   ```

3. **WSL permissions issues**: If you get permission errors in WSL, ensure the file line endings are Unix-style (LF, not CRLF).

4. **Node.js version issues**: The project now uses Node.js 20. If you need to use an older version, modify the Dockerfile accordingly.

### Getting Help

For more information about Azure Container Registry authentication, see the [main ACR authentication documentation](acr-auth.md).

## Best Practices

- Rotate your service principal credentials regularly
- Use the principle of least privilege (acrpull role when possible)
- Keep your credentials file secure and never commit it to version control
- Consider using Azure Key Vault for production credential storage
