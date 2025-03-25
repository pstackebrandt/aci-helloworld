#!/bin/bash
# =============================================================================
# Azure Container Registry Authentication Setup
# =============================================================================
# Purpose:
#   This script automates the entire process of:
#   1. Loading environment variables
#   2. Creating a service principal for ACR access
#   3. Securely storing the credentials
#
# Usage:
#   1. First, copy config/acr-env-template.sh to config/acr-env.sh and edit it
#   2. Run this script: ./scripts/setup-acr-auth.sh
# =============================================================================

set -e  # Exit immediately if a command fails

# Check if environment file exists
if [ ! -f "config/acr-env.sh" ]; then
  echo "Error: config/acr-env.sh not found."
  echo "Please create this file by copying from config/acr-env-template.sh"
  echo "and filling in your specific values."
  exit 1
fi

# Load environment variables
echo "Loading environment variables..."
source config/acr-env.sh

# Check if required variables are set
if [ -z "$containerRegistry" ] || [ -z "$servicePrincipal" ]; then
  echo "Error: Required environment variables are not set."
  echo "Please ensure containerRegistry and servicePrincipal are defined in config/acr-env.sh"
  exit 1
fi

echo "Creating service principal for $containerRegistry..."
# Run the service principal creation script and capture output
OUTPUT=$(./scripts/create-acr-service-principal.sh)
echo "$OUTPUT"

# Extract credentials from output
SP_ID=$(echo "$OUTPUT" | grep "Service principal ID:" | cut -d ' ' -f 4)
SP_PASSWORD=$(echo "$OUTPUT" | grep "Service principal password:" | cut -d ' ' -f 4)

# Check if credentials were successfully extracted
if [ -z "$SP_ID" ] || [ -z "$SP_PASSWORD" ]; then
  echo "Error: Failed to extract service principal credentials."
  exit 1
fi

# Store credentials
echo "Storing credentials securely..."
./scripts/store-acr-credentials.sh "$SP_ID" "$SP_PASSWORD"

echo "Setup complete! The credentials have been stored securely."
echo "You can now use them for Docker login or in your deployment scripts." 