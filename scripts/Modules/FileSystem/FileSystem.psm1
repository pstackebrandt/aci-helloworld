# =============================================================================
# FileSystem Module
# =============================================================================
# Purpose:
#   Provides functions for file system operations
# =============================================================================

function New-DirectoryIfNotExists {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
}

Export-ModuleMember -Function New-DirectoryIfNotExists 