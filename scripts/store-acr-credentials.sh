#!/bin/bash
# =============================================================================
# Store ACR Credentials Script
# =============================================================================
# Purpose:
#   Stores Azure Container Registry credentials securely
# =============================================================================

# Import common utilities
source "$(dirname "$0")/Modules/Common/bash-utils.sh"

# Check if credentials are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Service principal ID and password are required" >&2
    echo "Usage: $0 <service-principal-id> <service-principal-password>" >&2
    exit 1
fi

SP_ID="$1"
SP_PASSWORD="$2"

# Create timestamp for unique filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CREDENTIALS_DIR="config/secrets"
CREDENTIALS_FILE="$CREDENTIALS_DIR/acr-credentials_$TIMESTAMP.env"

# Create directory if it doesn't exist
mkdir -p "$CREDENTIALS_DIR"

# Store credentials
cat > "$CREDENTIALS_FILE" << EOF
# Azure Container Registry Credentials
# Generated on: $(date)
# For registry: ${containerRegistry}
# Service principal: ${servicePrincipal}

ACR_SERVICE_PRINCIPAL_ID=$SP_ID
ACR_SERVICE_PRINCIPAL_PASSWORD=$SP_PASSWORD
EOF

# Set restricted permissions
chmod 600 "$CREDENTIALS_FILE"

# Update .gitignore
update_gitignore "config/secrets/"

echo "Credentials stored in: $CREDENTIALS_FILE" >&2
echo "Important: Keep this file secure and don't commit it to version control!" >&2 