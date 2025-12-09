@{
    Run = @{
        Path = './Tests'
        Exit = $true
        PassThru = $true
    }
    CodeCoverage = @{
        Enabled = $true
        Path = @(
            './PSZoom/Public/**/*.ps1'
            './PSZoom/Private/**/*.ps1'
        )
        OutputFormat = 'JaCoCo'
        OutputPath = './Tests/coverage.xml'
        CoveragePercentTarget = 80
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = './Tests/testResults.xml'
    }
    Output = @{
        Verbosity = 'Detailed'
        StackTraceVerbosity = 'Filtered'
    }
    Filter = @{
        ExcludeTag = @('Integration')
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}
