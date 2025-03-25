#!/bin/bash
# =============================================================================
# Azure Container Registry Environment Variables
# =============================================================================
# Instructions:
# 1. Copy this file to config/acr-env.sh
# 2. Fill in your specific values for the variables
# 3. Source this file before running the service principal creation script:
#    source config/acr-env.sh
# =============================================================================

# Required variables
export containerRegistry="your-acr-name"
export servicePrincipal="acr-service-principal"

# Optional variables
# Uncomment and set these if you want to customize the script behavior
# export ACR_ROLE="acrpull"  # Options: acrpull, acrpush, owner 