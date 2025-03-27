# Line Endings Configuration
# Defines the expected line endings for different file types
# Values: LF (Unix \n) or CRLF (Windows \r\n)

@{
    FileTypes = @{
        # Shell scripts should use Unix line endings
        "*.sh" = "LF"
        
        # PowerShell scripts should use Windows line endings
        "*.ps1" = "CRLF"
        
        # Documentation and configuration files use Unix line endings
        "*.md" = "LF"
        "*.json" = "LF"
        "*.yml" = "LF"
        "*.yaml" = "LF"
        
        # Docker files should use Unix line endings
        "Dockerfile" = "LF"
        
        # Environment files should use Unix line endings
        "*.env" = "LF"
        "*.env.*" = "LF"
    }
} 