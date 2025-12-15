<#
.SYNOPSIS
    Tracks processed endpoints for idempotency in the API coverage sync system.

.DESCRIPTION
    Adds or updates entries in the processed-endpoints.json file to track
    which API endpoints have been processed (attempted for cmdlet generation),
    their results, and timestamps. This ensures the system doesn't repeatedly
    attempt to generate cmdlets for the same endpoints.

.PARAMETER EndpointHash
    The unique hash identifier for the endpoint (from gap report).

.PARAMETER Endpoint
    The endpoint path (e.g., /v2/users/{userId}/presence_status).

.PARAMETER Method
    The HTTP method (GET, POST, PUT, PATCH, DELETE).

.PARAMETER Result
    The processing result: 'success', 'failed', 'skipped'.

.PARAMETER CmdletName
    The name of the generated cmdlet (if successful).

.PARAMETER ErrorMessage
    Error message if processing failed.

.PARAMETER OutputPath
    Path to processed-endpoints.json. Defaults to data/processed-endpoints.json.

.EXAMPLE
    .\Add-ProcessedEndpoint.ps1 -EndpointHash "abc123" -Endpoint "/v2/users/{userId}/status" -Method "GET" -Result "success" -CmdletName "Get-ZoomUserStatus"

.EXAMPLE
    .\Add-ProcessedEndpoint.ps1 -EndpointHash "def456" -Endpoint "/v2/meetings/{meetingId}/livestream" -Method "PATCH" -Result "failed" -ErrorMessage "Validation failed"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, ParameterSetName = 'Single')]
    [string]$EndpointHash,

    [Parameter(Mandatory, ParameterSetName = 'Single')]
    [string]$Endpoint,

    [Parameter(Mandatory, ParameterSetName = 'Single')]
    [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
    [string]$Method,

    [Parameter(Mandatory, ParameterSetName = 'Single')]
    [ValidateSet('success', 'failed', 'skipped')]
    [string]$Result,

    [Parameter(ParameterSetName = 'Single')]
    [string]$CmdletName,

    [Parameter(ParameterSetName = 'Single')]
    [string]$ErrorMessage,

    [Parameter(ParameterSetName = 'Single')]
    [string]$GeneratedFiles,

    [Parameter(ParameterSetName = 'Batch')]
    [array]$Entries,

    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [switch]$PassThru
)

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

function Initialize-ProcessedEndpointsFile {
    param([string]$Path)

    $initial = [ordered]@{
        version    = '1.0'
        createdAt  = (Get-Date).ToUniversalTime().ToString('o')
        updatedAt  = (Get-Date).ToUniversalTime().ToString('o')
        statistics = [ordered]@{
            total     = 0
            success   = 0
            failed    = 0
            skipped   = 0
        }
        endpoints  = @()
    }

    $initial | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
    return $initial
}

#endregion

#region Main Logic

function Add-ProcessedEndpoint {
    [CmdletBinding()]
    param(
        [string]$EndpointHash,
        [string]$Endpoint,
        [string]$Method,
        [string]$Result,
        [string]$CmdletName,
        [string]$ErrorMessage,
        [string]$GeneratedFiles,
        [array]$Entries,
        [string]$OutputPath,
        [switch]$PassThru
    )

    # Set defaults
    $repoRoot = Get-RepoRoot

    if (-not $OutputPath) {
        $OutputPath = Join-Path $repoRoot 'data\processed-endpoints.json'
    }

    # Ensure directory exists
    $outputDir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    # Load or initialize the file
    if (Test-Path $OutputPath) {
        $data = Get-Content -Path $OutputPath -Raw | ConvertFrom-Json
        # Convert endpoints to a hashtable for easier updates
        $endpointMap = @{}
        foreach ($ep in $data.endpoints) {
            $endpointMap[$ep.hash] = $ep
        }
    }
    else {
        $data = Initialize-ProcessedEndpointsFile -Path $OutputPath
        $endpointMap = @{}
    }

    # Build entries to process
    $toProcess = @()

    if ($Entries) {
        $toProcess = $Entries
    }
    elseif ($EndpointHash) {
        $toProcess = @(@{
            hash          = $EndpointHash
            endpoint      = $Endpoint
            method        = $Method
            result        = $Result
            cmdletName    = $CmdletName
            errorMessage  = $ErrorMessage
            generatedFiles = $GeneratedFiles
        })
    }

    # Process each entry
    foreach ($entry in $toProcess) {
        $hash = $entry.hash

        $record = [ordered]@{
            hash           = $hash
            endpoint       = $entry.endpoint
            method         = $entry.method
            result         = $entry.result
            processedAt    = (Get-Date).ToUniversalTime().ToString('o')
        }

        if ($entry.cmdletName) {
            $record.cmdletName = $entry.cmdletName
        }

        if ($entry.errorMessage) {
            $record.errorMessage = $entry.errorMessage
        }

        if ($entry.generatedFiles) {
            $record.generatedFiles = $entry.generatedFiles
        }

        # Track attempt count for retries
        if ($endpointMap.ContainsKey($hash)) {
            $existing = $endpointMap[$hash]
            $record.attemptCount = ($existing.attemptCount ?? 0) + 1
            $record.firstProcessedAt = $existing.firstProcessedAt ?? $existing.processedAt
            $record.previousResults = @($existing.previousResults ?? @()) + @($existing.result)
        }
        else {
            $record.attemptCount = 1
            $record.firstProcessedAt = $record.processedAt
        }

        $endpointMap[$hash] = [PSCustomObject]$record

        Write-Host "  [TRACK] $($entry.method) $($entry.endpoint) -> $($entry.result)" -ForegroundColor $(
            switch ($entry.result) {
                'success' { 'Green' }
                'failed'  { 'Red' }
                'skipped' { 'Yellow' }
                default   { 'Gray' }
            }
        )
    }

    # Rebuild endpoints array
    $data.endpoints = $endpointMap.Values | Sort-Object processedAt -Descending

    # Update statistics
    $data.statistics = [ordered]@{
        total   = $data.endpoints.Count
        success = ($data.endpoints | Where-Object { $_.result -eq 'success' }).Count
        failed  = ($data.endpoints | Where-Object { $_.result -eq 'failed' }).Count
        skipped = ($data.endpoints | Where-Object { $_.result -eq 'skipped' }).Count
    }

    $data.updatedAt = (Get-Date).ToUniversalTime().ToString('o')

    # Save file
    $data | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputPath -Encoding UTF8

    Write-Host "`nProcessed endpoints updated: $OutputPath" -ForegroundColor Gray
    Write-Host "  Total: $($data.statistics.total) | Success: $($data.statistics.success) | Failed: $($data.statistics.failed) | Skipped: $($data.statistics.skipped)" -ForegroundColor Gray

    if ($PassThru) {
        return [PSCustomObject]$data
    }
}

# Helper function to clear/reset the processed endpoints file
function Clear-ProcessedEndpoints {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$OutputPath
    )

    $repoRoot = Get-RepoRoot

    if (-not $OutputPath) {
        $OutputPath = Join-Path $repoRoot 'data\processed-endpoints.json'
    }

    if ($PSCmdlet.ShouldProcess($OutputPath, 'Reset processed endpoints file')) {
        Initialize-ProcessedEndpointsFile -Path $OutputPath
        Write-Host "Processed endpoints file reset: $OutputPath" -ForegroundColor Yellow
    }
}

# Helper function to get processing statistics
function Get-ProcessedEndpointStats {
    param(
        [Parameter()]
        [string]$OutputPath
    )

    $repoRoot = Get-RepoRoot

    if (-not $OutputPath) {
        $OutputPath = Join-Path $repoRoot 'data\processed-endpoints.json'
    }

    if (-not (Test-Path $OutputPath)) {
        Write-Host "No processed endpoints file found at: $OutputPath" -ForegroundColor Yellow
        return $null
    }

    $data = Get-Content -Path $OutputPath -Raw | ConvertFrom-Json
    return $data.statistics
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    if ($Entries) {
        Add-ProcessedEndpoint -Entries $Entries -OutputPath $OutputPath -PassThru:$PassThru
    }
    elseif ($EndpointHash) {
        Add-ProcessedEndpoint -EndpointHash $EndpointHash -Endpoint $Endpoint -Method $Method -Result $Result -CmdletName $CmdletName -ErrorMessage $ErrorMessage -GeneratedFiles $GeneratedFiles -OutputPath $OutputPath -PassThru:$PassThru
    }
    else {
        Write-Host "Usage: Add-ProcessedEndpoint.ps1 -EndpointHash <hash> -Endpoint <path> -Method <method> -Result <result> [-CmdletName <name>] [-ErrorMessage <msg>]" -ForegroundColor Yellow
    }
}
