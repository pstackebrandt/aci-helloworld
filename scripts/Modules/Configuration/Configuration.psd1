@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789013'
    Author = 'Peter Stackebrandt'
    Description = 'Configuration validation module for ACR setup'
    PowerShellVersion = '5.1'
    
    # Functions to export
    FunctionsToExport = @(
        'Test-EnvironmentFile',
        'Test-Configuration'
    )
    
    # Dependencies
    RequiredModules = @(
        @{
            ModuleName = 'FileSystem'
            ModuleVersion = '1.0.0'
        }
    )
} 