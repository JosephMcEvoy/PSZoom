<#
.SYNOPSIS
    Unified test runner for PSZoom module.

.DESCRIPTION
    Runs Pester tests for the PSZoom module. Supports unit tests, integration tests,
    contract tests, or all tests. Works both locally and in CI environments.

.PARAMETER TestType
    Type of tests to run: Unit, Integration, Contract, or All.
    Default: Unit

.PARAMETER NoCoverage
    Skip code coverage collection. Speeds up test runs.

.PARAMETER OutputPath
    Directory for test results. Default: ./Tests

.PARAMETER PassThru
    Return the Pester result object.

.EXAMPLE
    ./Invoke-Tests.ps1
    Runs unit tests with code coverage.

.EXAMPLE
    ./Invoke-Tests.ps1 -TestType All -NoCoverage
    Runs all tests without code coverage.

.EXAMPLE
    ./Invoke-Tests.ps1 -TestType Integration
    Runs integration tests (requires Zoom API credentials).
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Unit', 'Integration', 'Contract', 'All')]
    [string]$TestType = 'Unit',

    [Parameter()]
    [switch]$NoCoverage,

    [Parameter()]
    [string]$OutputPath = './Tests',

    [Parameter()]
    [switch]$PassThru
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot

# Ensure Pester 5+ is available
$pester = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version.Major -ge 5 } | Select-Object -First 1
if (-not $pester) {
    Write-Error "Pester 5+ is required. Install with: Install-Module -Name Pester -MinimumVersion 5.0.0 -Force"
    exit 1
}
Import-Module Pester -MinimumVersion 5.0.0 -Force

# Build configuration based on test type
$config = New-PesterConfiguration

$config.Output.Verbosity = 'Detailed'
$config.Should.ErrorAction = 'Continue'
$config.Run.PassThru = $true

switch ($TestType) {
    'Unit' {
        Write-Host "`n=== Running Unit Tests ===" -ForegroundColor Cyan
        $config.Run.Path = "$ProjectRoot/Tests"
        $config.Filter.ExcludeTag = @('Integration', 'Contract')
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/testResults.xml"

        if (-not $NoCoverage) {
            $config.CodeCoverage.Enabled = $true
            $config.CodeCoverage.Path = @(
                "$ProjectRoot/PSZoom/Public/**/*.ps1"
                "$ProjectRoot/PSZoom/Private/**/*.ps1"
            )
            $config.CodeCoverage.OutputFormat = 'JaCoCo'
            $config.CodeCoverage.OutputPath = "$OutputPath/coverage.xml"
            $config.CodeCoverage.CoveragePercentTarget = 80
        }
    }
    'Integration' {
        Write-Host "`n=== Running Integration Tests ===" -ForegroundColor Cyan

        # Check for credentials
        if (-not $env:ZOOM_ACCOUNT_ID -or -not $env:ZOOM_CLIENT_ID -or -not $env:ZOOM_CLIENT_SECRET) {
            Write-Warning "Zoom API credentials not configured. Set ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, and ZOOM_CLIENT_SECRET environment variables."
            Write-Warning "Skipping integration tests."
            exit 0
        }

        $config.Run.Path = "$ProjectRoot/Tests/Integration"
        $config.Filter.Tag = @('Integration')
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/integrationTestResults.xml"
    }
    'Contract' {
        Write-Host "`n=== Running Contract Tests ===" -ForegroundColor Cyan
        $config.Run.Path = "$ProjectRoot/Tests/Contract"
        $config.Filter.Tag = @('Contract')
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/contractTestResults.xml"
    }
    'All' {
        Write-Host "`n=== Running All Tests ===" -ForegroundColor Cyan
        $config.Run.Path = "$ProjectRoot/Tests"
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/allTestResults.xml"

        if (-not $NoCoverage) {
            $config.CodeCoverage.Enabled = $true
            $config.CodeCoverage.Path = @(
                "$ProjectRoot/PSZoom/Public/**/*.ps1"
                "$ProjectRoot/PSZoom/Private/**/*.ps1"
            )
            $config.CodeCoverage.OutputFormat = 'JaCoCo'
            $config.CodeCoverage.OutputPath = "$OutputPath/coverage.xml"
            $config.CodeCoverage.CoveragePercentTarget = 80
        }
    }
}

# Run tests
$results = Invoke-Pester -Configuration $config

# Output summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Tests Run: $($results.TotalCount)"
Write-Host "Passed: $($results.PassedCount)" -ForegroundColor Green
Write-Host "Failed: $($results.FailedCount)" -ForegroundColor $(if ($results.FailedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "Skipped: $($results.SkippedCount)" -ForegroundColor Yellow

if ($results.CodeCoverage) {
    $coverage = [math]::Round(($results.CodeCoverage.CoveragePercent), 2)
    Write-Host "Code Coverage: $coverage%" -ForegroundColor $(if ($coverage -ge 80) { 'Green' } else { 'Yellow' })
}

# Return results or exit with appropriate code
if ($PassThru) {
    return $results
}

exit $results.FailedCount
