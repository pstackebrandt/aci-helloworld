# =============================================================================
# GitIgnore Module
# =============================================================================
# Purpose:
#   Provides functions for managing .gitignore file entries
# =============================================================================

function Update-GitIgnore {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        
        [Parameter(Mandatory=$false)]
        [switch]$Remove
    )
    
    $gitignorePath = ".gitignore"
    
    # Validate pattern
    if ([string]::IsNullOrWhiteSpace($Pattern)) {
        Write-Error "Pattern cannot be empty"
        return $false
    }
    
    # Handle file permissions
    try {
        if (Test-Path $gitignorePath) {
            $acl = Get-Acl $gitignorePath
            if ($acl.AreAccessRulesProtected) {
                Write-Warning "File permissions are protected. Attempting to modify..."
                $acl.SetAccessRuleProtection($false, $true)
                Set-Acl $gitignorePath $acl
            }
        }
    }
    catch {
        Write-Error "Failed to handle file permissions: $_"
        return $false
    }
    
    if ($Remove) {
        if (Test-Path $gitignorePath) {
            $content = Get-Content $gitignorePath -Raw
            $content = $content -replace "^$([regex]::Escape($Pattern))`r?`n", ""
            Set-Content -Path $gitignorePath -Value $content -NoNewline
            Write-Host "Removed $Pattern from .gitignore" -ForegroundColor Green
            return $true
        }
        return $false
    }
    
    if (Test-Path $gitignorePath) {
        $content = Get-Content $gitignorePath -Raw
        if (-not ($content -match "^$([regex]::Escape($Pattern))`r?`n")) {
            Add-Content -Path $gitignorePath -Value $Pattern
            Write-Host "Added $Pattern to .gitignore" -ForegroundColor Green
        }
    } else {
        $Pattern | Out-File -FilePath $gitignorePath -Encoding utf8
        Write-Host "Created .gitignore with $Pattern" -ForegroundColor Green
    }
    
    return $true
}

function Test-GitIgnorePattern {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Pattern
    )
    
    $gitignorePath = ".gitignore"
    if (Test-Path $gitignorePath) {
        $content = Get-Content $gitignorePath -Raw
        return $content -match "^$([regex]::Escape($Pattern))`r?`n"
    }
    return $false
}

function Get-GitIgnorePatterns {
    [CmdletBinding()]
    param ()
    
    $gitignorePath = ".gitignore"
    if (Test-Path $gitignorePath) {
        return Get-Content $gitignorePath
    }
    Write-Host "No .gitignore file found" -ForegroundColor Yellow
    return @()
}

# Export module members
Export-ModuleMember -Function Update-GitIgnore, Test-GitIgnorePattern, Get-GitIgnorePatterns 