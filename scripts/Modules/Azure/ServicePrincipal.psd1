@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Peter Stackebrandt'
    Description = 'Azure Service Principal management for ACR'
    PowerShellVersion = '5.1'
    
    # Functions to export
    FunctionsToExport = @(
        'New-AcrServicePrincipal',
        'Save-ServicePrincipalCredentials'
    )
    
    # Dependencies
    RequiredModules = @(
        @{ ModuleName = 'Az.Accounts'; ModuleVersion = '2.0.0' },
        @{ ModuleName = 'Az.Resources'; ModuleVersion = '6.0.0' },
        @{ ModuleName = 'Az.ContainerRegistry'; ModuleVersion = '3.0.0' }
    )
} 