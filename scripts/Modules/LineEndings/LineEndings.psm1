# =============================================================================
# Line Endings Module
# =============================================================================
# Purpose:
#   Provides functions for checking and fixing line endings in files
#
# Usage:
#   Import-Module LineEndings.psm1
#   Test-FileLineEndings -FilePath "file.txt" -ExpectedEnding "LF"
# =============================================================================

function Test-FileLineEndings {
    param(
        [string]$FilePath,
        [string]$ExpectedEnding
    )

    if (Test-Path $FilePath) {
        $content = Get-Content -Raw $FilePath
        $hasCRLF = $content -match "`r`n"

        if ($ExpectedEnding -eq "LF" -and $hasCRLF) {
            Write-Host "Warning: ${FilePath} contains CRLF line endings" -ForegroundColor Yellow
            Write-Host "Expected: LF (Unix) line endings" -ForegroundColor Yellow
            return $false
        }
        elseif ($ExpectedEnding -eq "CRLF" -and -not $hasCRLF) {
            Write-Host "Warning: ${FilePath} contains LF line endings" -ForegroundColor Yellow
            Write-Host "Expected: CRLF (Windows) line endings" -ForegroundColor Yellow
            return $false
        }
        return $true
    }
    return $false
}

function Set-FileLineEndings {
    param(
        [string]$FilePath,
        [string]$ExpectedEnding,
        [bool]$DryRun
    )

    if (Test-Path $FilePath) {
        if ($DryRun) {
            Write-Host "Would fix: ${FilePath}" -ForegroundColor Cyan
            Write-Host "  Change to: $ExpectedEnding line endings" -ForegroundColor Gray
            return
        }

        $content = Get-Content -Raw $FilePath
        if ($ExpectedEnding -eq "LF") {
            $content = $content -replace "`r`n", "`n"
        }
        elseif ($ExpectedEnding -eq "CRLF") {
            $content = $content -replace "`n", "`r`n"
        }
        Set-Content -Path $FilePath -Value $content -NoNewline
        Write-Host "Fixed: ${FilePath}" -ForegroundColor Green
    }
}

# Export functions
Export-ModuleMember -Function Test-FileLineEndings, Set-FileLineEndings 