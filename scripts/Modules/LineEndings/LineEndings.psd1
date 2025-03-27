@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Peter Stackebrandt'
    Description = 'Line ending management functions'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Test-FileLineEndings', 'Set-FileLineEndings')
    PrivateData = @{
        PSData = @{
            Tags = @('line-endings', 'git', 'text')
        }
    }
} 