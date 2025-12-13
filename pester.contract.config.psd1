# pester.contract.config.psd1
@{
    Run = @{
        Path = './Tests/Contract'
        Exit = $true
        PassThru = $true
    }
    Filter = @{
        Tag = @('Contract')
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = './Tests/contractTestResults.xml'
    }
    Output = @{
        Verbosity = 'Detailed'
        StackTraceVerbosity = 'Filtered'
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}
