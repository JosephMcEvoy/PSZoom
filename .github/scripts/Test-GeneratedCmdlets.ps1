<#
.SYNOPSIS
    Validates generated cmdlets using PSScriptAnalyzer and Pester.

.DESCRIPTION
    Runs validation gates on generated cmdlets to ensure they meet quality
    standards before committing. Includes syntax validation, PSScriptAnalyzer
    rules, and Pester tests.

.PARAMETER CmdletPaths
    Array of cmdlet file paths to validate.

.PARAMETER ResultsPath
    Path to generation-results.json to validate all generated cmdlets.

.PARAMETER RunTests
    Run Pester tests for the generated cmdlets.

.PARAMETER FixIssues
    Attempt to auto-fix PSScriptAnalyzer issues where possible.

.EXAMPLE
    .\Test-GeneratedCmdlets.ps1 -ResultsPath data/generation-results.json
    Validates all cmdlets from the latest generation run.

.OUTPUTS
    PSCustomObject containing validation results.
#>
[CmdletBinding()]
param(
    [Parameter(ParameterSetName = 'Paths')]
    [string[]]$CmdletPaths,

    [Parameter(ParameterSetName = 'Results')]
    [string]$ResultsPath,

    [Parameter()]
    [switch]$RunTests,

    [Parameter()]
    [switch]$FixIssues
)

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

function Test-PowerShellSyntax {
    param([string]$FilePath)

    $content = Get-Content -Path $FilePath -Raw
    $errors = $null

    try {
        $null = [System.Management.Automation.Language.Parser]::ParseInput(
            $content,
            [ref]$null,
            [ref]$errors
        )

        if ($errors.Count -gt 0) {
            return @{
                Valid  = $false
                Errors = $errors | ForEach-Object { $_.Message }
            }
        }

        return @{
            Valid  = $true
            Errors = @()
        }
    }
    catch {
        return @{
            Valid  = $false
            Errors = @($_.Exception.Message)
        }
    }
}

function Invoke-PSScriptAnalyzer {
    param(
        [string]$FilePath,
        [switch]$Fix
    )

    # Check if PSScriptAnalyzer is available
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Write-Warning "PSScriptAnalyzer module not found. Skipping analysis."
        return @{
            Passed   = $true
            Issues   = @()
            Skipped  = $true
        }
    }

    Import-Module PSScriptAnalyzer -ErrorAction SilentlyContinue

    $analysisParams = @{
        Path        = $FilePath
        Severity    = @('Error', 'Warning')
        ExcludeRule = @(
            'PSUseShouldProcessForStateChangingFunctions'  # API calls don't need -WhatIf
        )
    }

    if ($Fix) {
        $analysisParams.Fix = $true
    }

    $results = Invoke-ScriptAnalyzer @analysisParams

    $errors = $results | Where-Object { $_.Severity -eq 'Error' }
    $warnings = $results | Where-Object { $_.Severity -eq 'Warning' }

    return @{
        Passed   = $errors.Count -eq 0
        Issues   = $results
        Errors   = $errors
        Warnings = $warnings
        Skipped  = $false
    }
}

function Invoke-PesterTest {
    param([string]$TestPath)

    if (-not (Test-Path $TestPath)) {
        return @{
            Passed  = $false
            Error   = "Test file not found: $TestPath"
            Results = $null
        }
    }

    try {
        $config = New-PesterConfiguration
        $config.Run.Path = $TestPath
        $config.Run.PassThru = $true
        $config.Output.Verbosity = 'Minimal'

        $results = Invoke-Pester -Configuration $config

        return @{
            Passed      = $results.FailedCount -eq 0
            PassedCount = $results.PassedCount
            FailedCount = $results.FailedCount
            Results     = $results
        }
    }
    catch {
        return @{
            Passed  = $false
            Error   = $_.Exception.Message
            Results = $null
        }
    }
}

#endregion

#region Main Logic

function Test-GeneratedCmdlets {
    [CmdletBinding()]
    param(
        [string[]]$CmdletPaths,
        [string]$ResultsPath,
        [switch]$RunTests,
        [switch]$FixIssues
    )

    $repoRoot = Get-RepoRoot

    # Determine cmdlets to validate
    $cmdletsToValidate = @()

    if ($ResultsPath) {
        if (-not [System.IO.Path]::IsPathRooted($ResultsPath)) {
            $ResultsPath = Join-Path $repoRoot $ResultsPath
        }

        if (-not (Test-Path $ResultsPath)) {
            throw "Results file not found: $ResultsPath"
        }

        $generationResults = Get-Content -Path $ResultsPath -Raw | ConvertFrom-Json

        foreach ($item in $generationResults.generated) {
            $cmdletPath = Join-Path $repoRoot $item.cmdletPath.TrimStart('\', '/')
            $testPath = Join-Path $repoRoot $item.testPath.TrimStart('\', '/')

            $cmdletsToValidate += @{
                CmdletPath = $cmdletPath
                TestPath   = $testPath
                Name       = $item.cmdletName
            }
        }
    }
    elseif ($CmdletPaths) {
        foreach ($path in $CmdletPaths) {
            if (-not [System.IO.Path]::IsPathRooted($path)) {
                $path = Join-Path $repoRoot $path
            }

            $name = [System.IO.Path]::GetFileNameWithoutExtension($path)
            $testPath = $path -replace 'PSZoom\\Public', 'Tests\Unit\Public' -replace '\.ps1$', '.Tests.ps1'

            $cmdletsToValidate += @{
                CmdletPath = $path
                TestPath   = $testPath
                Name       = $name
            }
        }
    }
    else {
        throw "Either -CmdletPaths or -ResultsPath must be specified."
    }

    if ($cmdletsToValidate.Count -eq 0) {
        Write-Host "No cmdlets to validate." -ForegroundColor Yellow
        return
    }

    Write-Host "Validating $($cmdletsToValidate.Count) cmdlets..." -ForegroundColor Cyan

    $validationResults = @{
        timestamp  = (Get-Date).ToUniversalTime().ToString('o')
        cmdlets    = @()
        summary    = @{
            total         = $cmdletsToValidate.Count
            syntaxValid   = 0
            analyzerPassed = 0
            testsPassed   = 0
            overallPassed = 0
        }
    }

    foreach ($cmdlet in $cmdletsToValidate) {
        Write-Host "  [$($cmdlet.Name)]" -ForegroundColor Yellow

        $result = @{
            name          = $cmdlet.Name
            cmdletPath    = $cmdlet.CmdletPath
            testPath      = $cmdlet.TestPath
            syntaxValid   = $false
            analyzerPassed = $false
            testsPassed   = $false
            issues        = @()
        }

        # 1. Syntax validation
        Write-Host "    Syntax check..." -NoNewline
        if (Test-Path $cmdlet.CmdletPath) {
            $syntaxResult = Test-PowerShellSyntax -FilePath $cmdlet.CmdletPath

            if ($syntaxResult.Valid) {
                Write-Host " OK" -ForegroundColor Green
                $result.syntaxValid = $true
                $validationResults.summary.syntaxValid++
            }
            else {
                Write-Host " FAILED" -ForegroundColor Red
                $result.issues += $syntaxResult.Errors
            }
        }
        else {
            Write-Host " FILE NOT FOUND" -ForegroundColor Red
            $result.issues += "Cmdlet file not found"
        }

        # 2. PSScriptAnalyzer
        Write-Host "    PSScriptAnalyzer..." -NoNewline
        if ($result.syntaxValid) {
            $analyzerResult = Invoke-PSScriptAnalyzer -FilePath $cmdlet.CmdletPath -Fix:$FixIssues

            if ($analyzerResult.Skipped) {
                Write-Host " SKIPPED" -ForegroundColor Yellow
                $result.analyzerPassed = $true
                $validationResults.summary.analyzerPassed++
            }
            elseif ($analyzerResult.Passed) {
                Write-Host " OK" -ForegroundColor Green
                $result.analyzerPassed = $true
                $validationResults.summary.analyzerPassed++
            }
            else {
                Write-Host " $($analyzerResult.Errors.Count) errors" -ForegroundColor Red
                $result.issues += ($analyzerResult.Errors | ForEach-Object {
                    "$($_.RuleName): $($_.Message) (Line $($_.Line))"
                })
            }

            if ($analyzerResult.Warnings.Count -gt 0) {
                Write-Host "      Warnings: $($analyzerResult.Warnings.Count)" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host " SKIPPED (syntax invalid)" -ForegroundColor Yellow
        }

        # 3. Pester tests
        if ($RunTests) {
            Write-Host "    Pester tests..." -NoNewline
            if (Test-Path $cmdlet.TestPath) {
                $testResult = Invoke-PesterTest -TestPath $cmdlet.TestPath

                if ($testResult.Passed) {
                    Write-Host " OK ($($testResult.PassedCount) passed)" -ForegroundColor Green
                    $result.testsPassed = $true
                    $validationResults.summary.testsPassed++
                }
                else {
                    Write-Host " FAILED ($($testResult.FailedCount) failed)" -ForegroundColor Red
                    if ($testResult.Error) {
                        $result.issues += $testResult.Error
                    }
                }
            }
            else {
                Write-Host " TEST FILE NOT FOUND" -ForegroundColor Yellow
            }
        }
        else {
            $result.testsPassed = $null
        }

        # Overall pass
        $result.overallPassed = $result.syntaxValid -and $result.analyzerPassed
        if ($RunTests -and $result.testsPassed -ne $null) {
            $result.overallPassed = $result.overallPassed -and $result.testsPassed
        }

        if ($result.overallPassed) {
            $validationResults.summary.overallPassed++
        }

        $validationResults.cmdlets += $result
    }

    # Summary
    Write-Host "`nValidation Summary:" -ForegroundColor Cyan
    Write-Host "  Total:           $($validationResults.summary.total)" -ForegroundColor Gray
    Write-Host "  Syntax Valid:    $($validationResults.summary.syntaxValid)" -ForegroundColor $(if ($validationResults.summary.syntaxValid -eq $validationResults.summary.total) { 'Green' } else { 'Yellow' })
    Write-Host "  Analyzer Passed: $($validationResults.summary.analyzerPassed)" -ForegroundColor $(if ($validationResults.summary.analyzerPassed -eq $validationResults.summary.total) { 'Green' } else { 'Yellow' })
    if ($RunTests) {
        Write-Host "  Tests Passed:    $($validationResults.summary.testsPassed)" -ForegroundColor $(if ($validationResults.summary.testsPassed -eq $validationResults.summary.total) { 'Green' } else { 'Yellow' })
    }
    Write-Host "  Overall Passed:  $($validationResults.summary.overallPassed)" -ForegroundColor $(if ($validationResults.summary.overallPassed -eq $validationResults.summary.total) { 'Green' } else { 'Red' })

    return [PSCustomObject]$validationResults
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Test-GeneratedCmdlets -CmdletPaths $CmdletPaths -ResultsPath $ResultsPath -RunTests:$RunTests -FixIssues:$FixIssues
}
