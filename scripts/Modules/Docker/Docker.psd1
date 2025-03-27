@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Your Name'
    Description = 'Docker operations module for ACR integration'
    PowerShellVersion = '5.1'
    
    # Functions to export
    FunctionsToExport = @(
        'Test-DockerEnvironment',
        'Connect-DockerRegistry'
    )
    
    # Dependencies
    RequiredModules = @(
        @{
            ModuleName = 'LineEndings'
            ModuleVersion = '1.0.0'
        }
    )
} 