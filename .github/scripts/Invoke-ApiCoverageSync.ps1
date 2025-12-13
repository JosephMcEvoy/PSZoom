<#
.SYNOPSIS
    Master orchestration script for the API Coverage Sync pipeline.

.DESCRIPTION
    Runs the complete API coverage sync pipeline including:
    1. Downloading OpenAPI specs
    2. Parsing and normalizing endpoints
    3. Analyzing PSZoom coverage
    4. Generating gap report
    5. Optionally generating new cmdlets

.PARAMETER SkipDownload
    Skip downloading OpenAPI specs (use cached versions).

.PARAMETER GenerateCmdlets
    Generate new cmdlets for gap endpoints.

.PARAMETER MaxCmdlets
    Maximum number of cmdlets to generate (0 = unlimited).

.PARAMETER Priority
    Priority filter for gaps (high, medium, all).

.PARAMETER DryRun
    Preview mode - don't write any files.

.PARAMETER Validate
    Run validation on generated cmdlets.

.EXAMPLE
    .\Invoke-ApiCoverageSync.ps1
    Run full analysis pipeline without generating cmdlets.

.EXAMPLE
    .\Invoke-ApiCoverageSync.ps1 -GenerateCmdlets -MaxCmdlets 5 -Priority high
    Run full pipeline and generate up to 5 high-priority cmdlets.

.OUTPUTS
    PSCustomObject containing pipeline results.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipDownload,

    [Parameter()]
    [switch]$GenerateCmdlets,

    [Parameter()]
    [int]$MaxCmdlets = 5,

    [Parameter()]
    [ValidateSet('high', 'medium', 'all')]
    [string]$Priority = 'high',

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$Validate
)

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "$('=' * 60)" -ForegroundColor Cyan
}

function Write-StepResult {
    param(
        [string]$Message,
        [bool]$Success = $true
    )

    if ($Success) {
        Write-Host "[OK] $Message" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] $Message" -ForegroundColor Red
    }
}

#endregion

#region Main Logic

function Invoke-ApiCoverageSync {
    [CmdletBinding()]
    param(
        [switch]$SkipDownload,
        [switch]$GenerateCmdlets,
        [int]$MaxCmdlets,
        [string]$Priority,
        [switch]$DryRun,
        [switch]$Validate
    )

    $repoRoot = Get-RepoRoot
    $scriptsPath = Join-Path $repoRoot '.github\scripts'
    $dataPath = Join-Path $repoRoot 'data'

    $startTime = Get-Date

    $results = @{
        timestamp   = $startTime.ToUniversalTime().ToString('o')
        steps       = @()
        success     = $true
        duration    = $null
        summary     = @{}
    }

    try {
        # Step 1: Download OpenAPI Specs
        Write-Step "Step 1: Download OpenAPI Specs"

        if ($SkipDownload) {
            Write-Host "Skipping download (using cached specs)" -ForegroundColor Yellow
            $results.steps += @{ name = 'download'; status = 'skipped'; duration = 0 }
        }
        else {
            $stepStart = Get-Date
            try {
                & "$scriptsPath\Get-ZoomOpenApiSpecs.ps1"
                $duration = (Get-Date) - $stepStart
                Write-StepResult "Downloaded OpenAPI specs in $([int]$duration.TotalSeconds)s"
                $results.steps += @{ name = 'download'; status = 'success'; duration = $duration.TotalSeconds }
            }
            catch {
                Write-StepResult "Failed to download specs: $($_.Exception.Message)" -Success $false
                $results.steps += @{ name = 'download'; status = 'failed'; error = $_.Exception.Message }
                throw
            }
        }

        # Step 2: Parse OpenAPI Specs
        Write-Step "Step 2: Parse OpenAPI Specs"

        $stepStart = Get-Date
        try {
            $apiEndpoints = & "$scriptsPath\ConvertFrom-OpenApiSpec.ps1"
            $duration = (Get-Date) - $stepStart
            Write-StepResult "Parsed $($apiEndpoints.endpointCount) endpoints in $([int]$duration.TotalSeconds)s"
            $results.steps += @{ name = 'parse'; status = 'success'; duration = $duration.TotalSeconds; count = $apiEndpoints.endpointCount }
        }
        catch {
            Write-StepResult "Failed to parse specs: $($_.Exception.Message)" -Success $false
            $results.steps += @{ name = 'parse'; status = 'failed'; error = $_.Exception.Message }
            throw
        }

        # Step 3: Analyze PSZoom Coverage
        Write-Step "Step 3: Analyze PSZoom Coverage"

        $stepStart = Get-Date
        try {
            $coverage = & "$scriptsPath\Get-PSZoomCoverage.ps1"
            $duration = (Get-Date) - $stepStart
            Write-StepResult "Analyzed $($coverage.cmdletCount) cmdlets, $($coverage.endpointCount) endpoints in $([int]$duration.TotalSeconds)s"
            $results.steps += @{ name = 'coverage'; status = 'success'; duration = $duration.TotalSeconds; cmdlets = $coverage.cmdletCount; endpoints = $coverage.endpointCount }
        }
        catch {
            Write-StepResult "Failed to analyze coverage: $($_.Exception.Message)" -Success $false
            $results.steps += @{ name = 'coverage'; status = 'failed'; error = $_.Exception.Message }
            throw
        }

        # Step 4: Generate Gap Report
        Write-Step "Step 4: Generate Gap Report"

        $stepStart = Get-Date
        try {
            $gapReport = & "$scriptsPath\Get-ApiCoverageGaps.ps1"
            $duration = (Get-Date) - $stepStart

            $results.summary = @{
                totalEndpoints = $gapReport.summary.totalEndpoints
                covered        = $gapReport.summary.covered
                missing        = $gapReport.summary.missing
                coveragePercent = $gapReport.summary.coveragePercent
                newGaps        = $gapReport.summary.newGaps
            }

            Write-StepResult "Found $($gapReport.summary.newGaps) new gaps ($($gapReport.summary.coveragePercent)% coverage) in $([int]$duration.TotalSeconds)s"
            $results.steps += @{ name = 'gaps'; status = 'success'; duration = $duration.TotalSeconds; newGaps = $gapReport.summary.newGaps }
        }
        catch {
            Write-StepResult "Failed to generate gap report: $($_.Exception.Message)" -Success $false
            $results.steps += @{ name = 'gaps'; status = 'failed'; error = $_.Exception.Message }
            throw
        }

        # Step 5: Generate Cmdlets (optional)
        if ($GenerateCmdlets) {
            Write-Step "Step 5: Generate Cmdlets"

            if ($gapReport.summary.newGaps -eq 0) {
                Write-Host "No new gaps to process" -ForegroundColor Yellow
                $results.steps += @{ name = 'generate'; status = 'skipped'; reason = 'no gaps' }
            }
            elseif ($DryRun) {
                Write-Host "[DRY RUN] Would generate up to $MaxCmdlets cmdlets" -ForegroundColor Yellow
                $results.steps += @{ name = 'generate'; status = 'dry_run' }
            }
            else {
                $stepStart = Get-Date
                try {
                    $genParams = @{
                        GapReportPath = Join-Path $dataPath 'coverage-gap-report.json'
                        MaxCmdlets    = $MaxCmdlets
                        Priority      = $Priority
                    }

                    $genResult = & "$scriptsPath\New-ZoomCmdletFromGap.ps1" @genParams
                    $duration = (Get-Date) - $stepStart

                    Write-StepResult "Generated $($genResult.summary.generated) cmdlets in $([int]$duration.TotalSeconds)s"
                    $results.steps += @{
                        name      = 'generate'
                        status    = 'success'
                        duration  = $duration.TotalSeconds
                        generated = $genResult.summary.generated
                        failed    = $genResult.summary.failed
                    }

                    # Step 6: Validate (optional)
                    if ($Validate -and $genResult.summary.generated -gt 0) {
                        Write-Step "Step 6: Validate Generated Cmdlets"

                        $stepStart = Get-Date
                        try {
                            $validation = & "$scriptsPath\Test-GeneratedCmdlets.ps1" -ResultsPath (Join-Path $dataPath 'generation-results.json')
                            $duration = (Get-Date) - $stepStart

                            $passed = $validation.summary.overallPassed
                            $total = $validation.summary.total

                            if ($passed -eq $total) {
                                Write-StepResult "All $total cmdlets passed validation in $([int]$duration.TotalSeconds)s"
                            }
                            else {
                                Write-StepResult "$passed/$total cmdlets passed validation" -Success $false
                            }

                            $results.steps += @{
                                name     = 'validate'
                                status   = if ($passed -eq $total) { 'success' } else { 'partial' }
                                duration = $duration.TotalSeconds
                                passed   = $passed
                                total    = $total
                            }
                        }
                        catch {
                            Write-StepResult "Validation failed: $($_.Exception.Message)" -Success $false
                            $results.steps += @{ name = 'validate'; status = 'failed'; error = $_.Exception.Message }
                        }
                    }
                }
                catch {
                    Write-StepResult "Generation failed: $($_.Exception.Message)" -Success $false
                    $results.steps += @{ name = 'generate'; status = 'failed'; error = $_.Exception.Message }
                    throw
                }
            }
        }
    }
    catch {
        $results.success = $false
        Write-Host "`nPipeline failed: $($_.Exception.Message)" -ForegroundColor Red
    }

    $endTime = Get-Date
    $results.duration = ($endTime - $startTime).TotalSeconds

    # Final Summary
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host " Pipeline Complete" -ForegroundColor Cyan
    Write-Host "$('=' * 60)" -ForegroundColor Cyan

    Write-Host "Duration: $([int]$results.duration)s" -ForegroundColor Gray
    Write-Host "Success: $($results.success)" -ForegroundColor $(if ($results.success) { 'Green' } else { 'Red' })

    if ($results.summary.Count -gt 0) {
        Write-Host "`nCoverage Summary:" -ForegroundColor Cyan
        Write-Host "  Total Endpoints: $($results.summary.totalEndpoints)" -ForegroundColor Gray
        Write-Host "  Covered: $($results.summary.covered) ($($results.summary.coveragePercent)%)" -ForegroundColor Gray
        Write-Host "  Missing: $($results.summary.missing)" -ForegroundColor Gray
        Write-Host "  New Gaps: $($results.summary.newGaps)" -ForegroundColor Gray
    }

    return [PSCustomObject]$results
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-ApiCoverageSync -SkipDownload:$SkipDownload -GenerateCmdlets:$GenerateCmdlets -MaxCmdlets $MaxCmdlets -Priority $Priority -DryRun:$DryRun -Validate:$Validate
}
