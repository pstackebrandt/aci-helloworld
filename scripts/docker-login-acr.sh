#!/bin/bash
# =============================================================================
# Docker Login to Azure Container Registry
# =============================================================================
# Purpose:
#   This script loads the stored service principal credentials and uses them
#   to log in to an Azure Container Registry with Docker.
#
# Usage:
#   ./scripts/docker-login-acr.sh [credentials_file]
#
#   If credentials_file is not specified, the script will use the most recently
#   created credentials file in config/secrets/.
# =============================================================================

# Use specified credentials file or find the most recent one
if [ $# -eq 1 ]; then
  CREDENTIALS_FILE="$1"
  
  if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Error: Specified credentials file '$CREDENTIALS_FILE' not found."
    exit 1
  fi
else
  # Find the most recent credentials file
  CREDENTIALS_FILE=$(find config/secrets -name "acr-credentials_*.env" -type f | sort -r | head -n 1)
  
  if [ -z "$CREDENTIALS_FILE" ]; then
    echo "Error: No credentials files found in config/secrets/."
    echo "Please run scripts/setup-acr-auth.sh first."
    exit 1
  fi
  
  echo "Using most recent credentials file: $CREDENTIALS_FILE"
fi

# Load credentials
echo "Loading credentials from $CREDENTIALS_FILE..."
source "$CREDENTIALS_FILE"

# Check if required variables are loaded
if [ -z "$ACR_SERVICE_PRINCIPAL_ID" ] || [ -z "$ACR_SERVICE_PRINCIPAL_PASSWORD" ]; then
  echo "Error: Required credentials not found in $CREDENTIALS_FILE."
  exit 1
fi

# Load registry name from environment or prompt user
if [ -z "$containerRegistry" ]; then
  # Try to extract from credentials file comment
  REGISTRY_LINE=$(grep "For registry:" "$CREDENTIALS_FILE" || echo "")
  if [[ "$REGISTRY_LINE" =~ For\ registry:\ ([a-zA-Z0-9\-]+) ]]; then
    containerRegistry="${BASH_REMATCH[1]}"
  else
    read -p "Enter ACR registry name: " containerRegistry
  fi
fi

# Perform docker login
echo "Logging in to ${containerRegistry}.azurecr.io..."
docker login "${containerRegistry}.azurecr.io" \
  --username "$ACR_SERVICE_PRINCIPAL_ID" \
  --password "$ACR_SERVICE_PRINCIPAL_PASSWORD"

echo "Login successful. You can now push/pull images from ${containerRegistry}.azurecr.io" 