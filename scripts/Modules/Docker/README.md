# Docker Module

This module provides centralized functions for Docker operations with Azure Container Registry (ACR).

## Functions

### Test-DockerEnvironment
Validates the Docker environment configuration.

```powershell
Test-DockerEnvironment [-EnvFile <string>]
```

Parameters:
- `EnvFile`: Path to the environment file (default: "config/acr-env.sh")

Returns:
- `$true` if environment is valid
- `$false` if validation fails

### Connect-DockerRegistry
Connects to the Azure Container Registry using environment configuration.

```powershell
Connect-DockerRegistry [-EnvFile <string>] [-DryRun]
```

Parameters:
- `EnvFile`: Path to the environment file (default: "config/acr-env.sh")
- `DryRun`: Preview the login command without executing it

Returns:
- `$true` if login successful
- `$false` if login fails

## Dependencies
- LineEndings module (version 1.0.0 or higher)

## Usage Example
```powershell
# Import the module
Import-Module .\Docker.psm1

# Test environment
Test-DockerEnvironment

# Connect to registry
Connect-DockerRegistry

# Preview login command
Connect-DockerRegistry -DryRun
```

## Environment File Requirements
The environment file (acr-env.sh) must contain:
- `containerRegistry`: ACR name
- `servicePrincipal`: Service principal name
- `password`: Service principal password 