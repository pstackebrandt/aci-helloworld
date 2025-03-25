#!/bin/bash
# =============================================================================
# Store Azure Container Registry Credentials
# =============================================================================
# Purpose:
#   This script securely stores the credentials for an Azure Container Registry
#   service principal for later use.
#
# Usage:
#   Run this script immediately after create-acr-service-principal.sh:
#   ./scripts/store-acr-credentials.sh SERVICE_PRINCIPAL_ID SERVICE_PRINCIPAL_PASSWORD
# =============================================================================

if [ $# -ne 2 ]; then
  echo "Usage: $0 <service_principal_id> <service_principal_password>"
  exit 1
fi

SERVICE_PRINCIPAL_ID=$1
SERVICE_PRINCIPAL_PASSWORD=$2
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CREDENTIALS_FILE="config/secrets/acr-credentials_${TIMESTAMP}.env"

# Create secrets directory if it doesn't exist
mkdir -p config/secrets

# Store credentials in the file
cat > "$CREDENTIALS_FILE" << EOF
# Azure Container Registry Credentials
# Generated on: $(date)
# For registry: $containerRegistry
# Service principal: $servicePrincipal

ACR_SERVICE_PRINCIPAL_ID=$SERVICE_PRINCIPAL_ID
ACR_SERVICE_PRINCIPAL_PASSWORD=$SERVICE_PRINCIPAL_PASSWORD
EOF

# Set strict permissions on the credentials file
chmod 600 "$CREDENTIALS_FILE"

echo "Credentials stored in: $CREDENTIALS_FILE"
echo "Important: Keep this file secure and don't commit it to version control!"

# Create a .gitignore entry if it doesn't exist
if ! grep -q "config/secrets/" .gitignore 2>/dev/null; then
  echo "Adding config/secrets/ to .gitignore"
  echo "config/secrets/" >> .gitignore
fi 