<#
.SYNOPSIS
    Reverts generated cmdlets from a specific generation run.

.DESCRIPTION
    Uses the generation results manifest to identify and remove cmdlets,
    tests, and fixtures created by a specific generation run. Supports
    dry-run mode for previewing changes.

.PARAMETER ResultsPath
    Path to generation-results.json from a specific run.

.PARAMETER DryRun
    Preview changes without actually deleting files.

.PARAMETER Force
    Skip confirmation prompts.

.EXAMPLE
    .\Undo-GeneratedCmdlets.ps1 -ResultsPath data/generation-results.json -DryRun
    Preview what would be deleted without making changes.

.EXAMPLE
    .\Undo-GeneratedCmdlets.ps1 -ResultsPath data/generation-results.json -Force
    Delete all files from the generation run without prompting.

.OUTPUTS
    PSCustomObject containing rollback results.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ResultsPath,

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$Force
)

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

#endregion

#region Main Logic

function Invoke-UndoGeneratedCmdlets {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ResultsPath,
        [switch]$DryRun,
        [switch]$Force
    )

    $repoRoot = Get-RepoRoot

    # Resolve results path
    if (-not [System.IO.Path]::IsPathRooted($ResultsPath)) {
        $ResultsPath = Join-Path $repoRoot $ResultsPath
    }

    if (-not (Test-Path $ResultsPath)) {
        throw "Results file not found: $ResultsPath"
    }

    # Load generation results
    $results = Get-Content -Path $ResultsPath -Raw | ConvertFrom-Json

    if (-not $results.generated -or $results.generated.Count -eq 0) {
        Write-Host "No generated items found in results file." -ForegroundColor Yellow
        return
    }

    Write-Host "Rollback for generation run: $($results.timestamp)" -ForegroundColor Cyan
    Write-Host "Total items to rollback: $($results.generated.Count)" -ForegroundColor Cyan

    if ($DryRun) {
        Write-Host "`n[DRY RUN MODE - No files will be deleted]`n" -ForegroundColor Yellow
    }

    $rollbackResults = @{
        timestamp     = (Get-Date).ToUniversalTime().ToString('o')
        sourceResults = $ResultsPath
        dryRun        = $DryRun.IsPresent
        items         = @()
        summary       = @{
            total          = $results.generated.Count
            cmdletsDeleted = 0
            testsDeleted   = 0
            fixturesDeleted = 0
            errors         = 0
        }
    }

    # Confirmation prompt
    if (-not $DryRun -and -not $Force) {
        Write-Host "`nFiles to be deleted:" -ForegroundColor Yellow
        foreach ($item in $results.generated) {
            $cmdletPath = Join-Path $repoRoot $item.cmdletPath.TrimStart('\', '/')
            $testPath = Join-Path $repoRoot $item.testPath.TrimStart('\', '/')

            Write-Host "  - $($item.cmdletPath)" -ForegroundColor Gray
            Write-Host "  - $($item.testPath)" -ForegroundColor Gray

            if ($item.fixturePath) {
                Write-Host "  - $($item.fixturePath)" -ForegroundColor Gray
            }
        }

        $response = Read-Host "`nAre you sure you want to delete these files? (yes/no)"
        if ($response -ne 'yes') {
            Write-Host "Rollback cancelled." -ForegroundColor Yellow
            return
        }
    }

    # Process each generated item
    foreach ($item in $results.generated) {
        Write-Host "`n[$($item.cmdletName)]" -ForegroundColor Yellow

        $itemResult = @{
            cmdletName     = $item.cmdletName
            endpointId     = $item.endpointId
            filesDeleted   = @()
            errors         = @()
        }

        # Delete cmdlet file
        $cmdletPath = Join-Path $repoRoot $item.cmdletPath.TrimStart('\', '/')
        if (Test-Path $cmdletPath) {
            Write-Host "  Cmdlet: $cmdletPath" -NoNewline
            if ($DryRun) {
                Write-Host " [WOULD DELETE]" -ForegroundColor Yellow
                $itemResult.filesDeleted += @{ path = $cmdletPath; type = 'cmdlet'; deleted = $false }
            }
            else {
                try {
                    Remove-Item -Path $cmdletPath -Force
                    Write-Host " [DELETED]" -ForegroundColor Green
                    $itemResult.filesDeleted += @{ path = $cmdletPath; type = 'cmdlet'; deleted = $true }
                    $rollbackResults.summary.cmdletsDeleted++
                }
                catch {
                    Write-Host " [ERROR: $($_.Exception.Message)]" -ForegroundColor Red
                    $itemResult.errors += "Failed to delete cmdlet: $($_.Exception.Message)"
                    $rollbackResults.summary.errors++
                }
            }
        }
        else {
            Write-Host "  Cmdlet: $cmdletPath [NOT FOUND]" -ForegroundColor DarkGray
        }

        # Delete test file
        $testPath = Join-Path $repoRoot $item.testPath.TrimStart('\', '/')
        if (Test-Path $testPath) {
            Write-Host "  Test: $testPath" -NoNewline
            if ($DryRun) {
                Write-Host " [WOULD DELETE]" -ForegroundColor Yellow
                $itemResult.filesDeleted += @{ path = $testPath; type = 'test'; deleted = $false }
            }
            else {
                try {
                    Remove-Item -Path $testPath -Force
                    Write-Host " [DELETED]" -ForegroundColor Green
                    $itemResult.filesDeleted += @{ path = $testPath; type = 'test'; deleted = $true }
                    $rollbackResults.summary.testsDeleted++
                }
                catch {
                    Write-Host " [ERROR: $($_.Exception.Message)]" -ForegroundColor Red
                    $itemResult.errors += "Failed to delete test: $($_.Exception.Message)"
                    $rollbackResults.summary.errors++
                }
            }
        }
        else {
            Write-Host "  Test: $testPath [NOT FOUND]" -ForegroundColor DarkGray
        }

        # Delete fixture file if exists
        if ($item.fixturePath) {
            $fixturePath = Join-Path $repoRoot $item.fixturePath.TrimStart('\', '/')
            if (Test-Path $fixturePath) {
                Write-Host "  Fixture: $fixturePath" -NoNewline
                if ($DryRun) {
                    Write-Host " [WOULD DELETE]" -ForegroundColor Yellow
                    $itemResult.filesDeleted += @{ path = $fixturePath; type = 'fixture'; deleted = $false }
                }
                else {
                    try {
                        Remove-Item -Path $fixturePath -Force
                        Write-Host " [DELETED]" -ForegroundColor Green
                        $itemResult.filesDeleted += @{ path = $fixturePath; type = 'fixture'; deleted = $true }
                        $rollbackResults.summary.fixturesDeleted++
                    }
                    catch {
                        Write-Host " [ERROR: $($_.Exception.Message)]" -ForegroundColor Red
                        $itemResult.errors += "Failed to delete fixture: $($_.Exception.Message)"
                        $rollbackResults.summary.errors++
                    }
                }
            }
            else {
                Write-Host "  Fixture: $fixturePath [NOT FOUND]" -ForegroundColor DarkGray
            }
        }

        $rollbackResults.items += $itemResult
    }

    # Remove endpoint tracking entries if not dry run
    if (-not $DryRun) {
        $processedPath = Join-Path $repoRoot 'data\processed-endpoints.json'
        if (Test-Path $processedPath) {
            try {
                $processed = Get-Content -Path $processedPath -Raw | ConvertFrom-Json
                $endpointIds = $results.generated | ForEach-Object { $_.endpointId }

                $originalCount = $processed.endpoints.Count
                $processed.endpoints = $processed.endpoints | Where-Object { $_.id -notin $endpointIds }
                $removedCount = $originalCount - $processed.endpoints.Count

                if ($removedCount -gt 0) {
                    $processed.lastUpdated = (Get-Date).ToUniversalTime().ToString('o')
                    $processed | ConvertTo-Json -Depth 100 | Set-Content -Path $processedPath -Encoding UTF8
                    Write-Host "`nRemoved $removedCount entries from processed-endpoints.json" -ForegroundColor Green
                }
            }
            catch {
                Write-Warning "Failed to update processed-endpoints.json: $($_.Exception.Message)"
            }
        }
    }

    # Summary
    Write-Host "`nRollback Summary:" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "  [DRY RUN - No changes made]" -ForegroundColor Yellow
    }
    Write-Host "  Items processed: $($rollbackResults.summary.total)" -ForegroundColor Gray
    Write-Host "  Cmdlets deleted: $($rollbackResults.summary.cmdletsDeleted)" -ForegroundColor $(if ($rollbackResults.summary.cmdletsDeleted -gt 0) { 'Green' } else { 'Gray' })
    Write-Host "  Tests deleted:   $($rollbackResults.summary.testsDeleted)" -ForegroundColor $(if ($rollbackResults.summary.testsDeleted -gt 0) { 'Green' } else { 'Gray' })
    Write-Host "  Fixtures deleted: $($rollbackResults.summary.fixturesDeleted)" -ForegroundColor $(if ($rollbackResults.summary.fixturesDeleted -gt 0) { 'Green' } else { 'Gray' })

    if ($rollbackResults.summary.errors -gt 0) {
        Write-Host "  Errors: $($rollbackResults.summary.errors)" -ForegroundColor Red
    }

    return [PSCustomObject]$rollbackResults
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-UndoGeneratedCmdlets -ResultsPath $ResultsPath -DryRun:$DryRun -Force:$Force
}
