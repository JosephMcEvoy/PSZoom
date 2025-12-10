@{
    Run = @{
        Path = './Tests/Integration'
        Exit = $true
        PassThru = $true
    }
    Filter = @{
        Tag = @('Integration')
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = './Tests/integrationTestResults.xml'
    }
    Output = @{
        Verbosity = 'Detailed'
        StackTraceVerbosity = 'Filtered'
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}
