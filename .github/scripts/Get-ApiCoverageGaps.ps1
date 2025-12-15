<#
.SYNOPSIS
    Compares Zoom API endpoints against PSZoom coverage to identify gaps.

.DESCRIPTION
    Reads the normalized Zoom API endpoints and PSZoom coverage data,
    performs intelligent matching to identify which API endpoints are
    not yet implemented as PSZoom cmdlets, and generates a prioritized
    gap report.

.PARAMETER EndpointsPath
    Path to zoom-api-endpoints.json. Defaults to data/zoom-api-endpoints.json.

.PARAMETER CoveragePath
    Path to pszoom-coverage.json. Defaults to data/pszoom-coverage.json.

.PARAMETER OutputPath
    Path for the gap report JSON. Defaults to data/coverage-gap-report.json.

.PARAMETER ProcessedPath
    Path to processed-endpoints.json for idempotency. Defaults to data/processed-endpoints.json.

.EXAMPLE
    .\Get-ApiCoverageGaps.ps1
    Generates a gap report comparing API endpoints to PSZoom coverage.

.OUTPUTS
    PSCustomObject containing the gap analysis report.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$EndpointsPath,

    [Parameter()]
    [string]$CoveragePath,

    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [string]$ProcessedPath
)

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

function Get-EndpointHash {
    param(
        [string]$Method,
        [string]$Path
    )

    $hashInput = "$($Method.ToUpper())|$Path"
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($hashInput)
    $hash = $sha256.ComputeHash($bytes)
    return [BitConverter]::ToString($hash).Replace('-', '').Substring(0, 16).ToLower()
}

function ConvertTo-CmdletName {
    <#
    .SYNOPSIS
        Suggests a PowerShell cmdlet name for a Zoom API endpoint.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Path,

        [string]$OperationId
    )

    # Determine verb based on HTTP method
    $verb = switch ($Method.ToUpper()) {
        'GET'    { 'Get' }
        'POST'   { 'New' }
        'PUT'    { 'Set' }
        'PATCH'  { 'Update' }
        'DELETE' { 'Remove' }
        default  { 'Invoke' }
    }

    # Extract noun from path
    $pathParts = $Path -replace '/v2/', '' -split '/' | Where-Object { $_ -and $_ -notmatch '^\{' }

    # Build noun
    $noun = 'Zoom'

    # Handle common patterns
    if ($pathParts.Count -ge 1) {
        # Singularize and PascalCase each part
        foreach ($part in $pathParts) {
            # Skip common noise words
            if ($part -in @('me', 'settings', 'status')) {
                $noun += (Get-Culture).TextInfo.ToTitleCase($part)
                continue
            }

            # Singularize
            $singular = $part
            if ($singular -match 's$' -and $singular -notmatch '(status|settings|ss)$') {
                $singular = $singular -replace 's$', ''
            }

            # PascalCase
            $noun += (Get-Culture).TextInfo.ToTitleCase($singular)
        }
    }

    # Use operationId if available and noun is too generic
    if ($OperationId -and $noun -eq 'Zoom') {
        $noun = 'Zoom' + (Get-Culture).TextInfo.ToTitleCase($OperationId)
    }

    # Clean up
    $noun = $noun -replace '[^a-zA-Z0-9]', ''

    return "$verb-$noun"
}

function Get-EndpointPriority {
    <#
    .SYNOPSIS
        Assigns priority to an endpoint based on product and category.
    #>
    param(
        [Parameter(Mandatory)]
        [object]$Endpoint
    )

    # High priority: Core Zoom functionality
    $highPriorityProducts = @('meetings', 'users', 'webinars', 'accounts', 'groups')
    $highPriorityCategories = @('meetings', 'users', 'webinars', 'accounts', 'groups', 'roles')

    # Medium priority: Extended functionality
    $mediumPriorityProducts = @('phone', 'rooms', 'team-chat', 'reports', 'dashboards')

    # Low priority: Specialized
    $lowPriorityProducts = @('contact-center', 'video-sdk', 'events')

    if ($Endpoint.product -in $highPriorityProducts -or $Endpoint.category -in $highPriorityCategories) {
        return 'high'
    }
    elseif ($Endpoint.product -in $mediumPriorityProducts) {
        return 'medium'
    }
    elseif ($Endpoint.product -in $lowPriorityProducts) {
        return 'low'
    }

    return 'medium'
}

function Test-EndpointMatch {
    <#
    .SYNOPSIS
        Checks if a Zoom API endpoint matches a PSZoom endpoint using fuzzy matching.
    #>
    param(
        [Parameter(Mandatory)]
        [object]$ApiEndpoint,

        [Parameter(Mandatory)]
        [array]$CoverageEndpoints
    )

    $apiPath = $ApiEndpoint.path
    $apiMethod = $ApiEndpoint.method.ToUpper()

    foreach ($covered in $CoverageEndpoints) {
        $coveredPath = $covered.path
        $coveredMethod = $covered.method.ToUpper()

        # Method must match
        if ($apiMethod -ne $coveredMethod) {
            continue
        }

        # Exact match
        if ($apiPath -eq $coveredPath) {
            return $true
        }

        # Normalize paths for comparison
        $normalizedApi = $apiPath -replace '\{[^}]+\}', '{id}' -replace '/$', ''
        $normalizedCovered = $coveredPath -replace '\{[^}]+\}', '{id}' -replace '/$', ''

        if ($normalizedApi -eq $normalizedCovered) {
            return $true
        }

        # Check if covered path is a prefix (API might have more specific endpoints)
        # e.g., /v2/users matches /v2/users/{userId}
        if ($normalizedApi.StartsWith($normalizedCovered) -or $normalizedCovered.StartsWith($normalizedApi)) {
            # More specific match logic could go here
        }
    }

    return $false
}

#endregion

#region Main Logic

function Invoke-GetApiCoverageGaps {
    [CmdletBinding()]
    param(
        [string]$EndpointsPath,
        [string]$CoveragePath,
        [string]$OutputPath,
        [string]$ProcessedPath
    )

    # Set defaults
    $repoRoot = Get-RepoRoot
    $dataDir = Join-Path $repoRoot 'data'

    if (-not $EndpointsPath) {
        $EndpointsPath = Join-Path $dataDir 'zoom-api-endpoints.json'
    }

    if (-not $CoveragePath) {
        $CoveragePath = Join-Path $dataDir 'pszoom-coverage.json'
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path $dataDir 'coverage-gap-report.json'
    }

    if (-not $ProcessedPath) {
        $ProcessedPath = Join-Path $dataDir 'processed-endpoints.json'
    }

    # Validate input files
    if (-not (Test-Path $EndpointsPath)) {
        throw "Endpoints file not found: $EndpointsPath. Run ConvertFrom-OpenApiSpec.ps1 first."
    }

    if (-not (Test-Path $CoveragePath)) {
        throw "Coverage file not found: $CoveragePath. Run Get-PSZoomCoverage.ps1 first."
    }

    Write-Host "Loading API endpoints and coverage data..." -ForegroundColor Cyan

    # Load data
    $apiEndpoints = (Get-Content -Path $EndpointsPath -Raw | ConvertFrom-Json).endpoints
    $pszoomCoverage = Get-Content -Path $CoveragePath -Raw | ConvertFrom-Json
    $coveredEndpoints = $pszoomCoverage.endpoints

    # Load processed endpoints for idempotency
    $processedEndpoints = @{}
    if (Test-Path $ProcessedPath) {
        $processed = Get-Content -Path $ProcessedPath -Raw | ConvertFrom-Json
        if ($processed.endpoints) {
            foreach ($ep in $processed.endpoints) {
                $processedEndpoints[$ep.hash] = $ep
            }
        }
    }

    Write-Host "  API Endpoints: $($apiEndpoints.Count)" -ForegroundColor Gray
    Write-Host "  Covered Endpoints: $($coveredEndpoints.Count)" -ForegroundColor Gray
    Write-Host "  Previously Processed: $($processedEndpoints.Count)" -ForegroundColor Gray

    # Identify gaps
    Write-Host "`nAnalyzing coverage gaps..." -ForegroundColor Cyan

    $gaps = @()
    $covered = @()
    $skipped = @()

    foreach ($endpoint in $apiEndpoints) {
        # Skip deprecated endpoints
        if ($endpoint.deprecated) {
            $skipped += @{
                endpoint = $endpoint
                reason   = 'deprecated'
            }
            continue
        }

        # Check if already covered
        $isCovered = Test-EndpointMatch -ApiEndpoint $endpoint -CoverageEndpoints $coveredEndpoints

        if ($isCovered) {
            $covered += $endpoint
            continue
        }

        # Check if already processed (for idempotency)
        $wasProcessed = $processedEndpoints.ContainsKey($endpoint.id)

        $gap = [ordered]@{
            hash              = $endpoint.id
            endpoint          = $endpoint.path
            method            = $endpoint.method
            product           = $endpoint.product
            category          = $endpoint.category
            operationId       = $endpoint.operationId
            summary           = $endpoint.summary
            description       = $endpoint.description
            parameters        = $endpoint.parameters
            scopes            = $endpoint.scopes
            priority          = Get-EndpointPriority -Endpoint $endpoint
            suggestedCmdletName = ConvertTo-CmdletName -Method $endpoint.method -Path $endpoint.path -OperationId $endpoint.operationId
            previouslyProcessed = $wasProcessed
        }

        if ($wasProcessed) {
            $gap.processedAt = $processedEndpoints[$endpoint.id].processedAt
            $gap.processedResult = $processedEndpoints[$endpoint.id].result
        }

        $gaps += $gap
    }

    # Calculate statistics
    $totalEndpoints = $apiEndpoints.Count
    $coveredCount = $covered.Count
    $missingCount = $gaps.Count
    $coveragePercent = if ($totalEndpoints -gt 0) { [math]::Round(($coveredCount / $totalEndpoints) * 100, 1) } else { 0 }

    # Group by category
    $byCategory = @{}
    foreach ($endpoint in $apiEndpoints) {
        $cat = $endpoint.category
        if (-not $byCategory.ContainsKey($cat)) {
            $byCategory[$cat] = @{ total = 0; covered = 0; missing = 0 }
        }
        $byCategory[$cat].total++
    }
    foreach ($ep in $covered) {
        if ($byCategory.ContainsKey($ep.category)) {
            $byCategory[$ep.category].covered++
        }
    }
    foreach ($gap in $gaps) {
        if ($byCategory.ContainsKey($gap.category)) {
            $byCategory[$gap.category].missing++
        }
    }

    # Group by product
    $byProduct = @{}
    foreach ($endpoint in $apiEndpoints) {
        $prod = $endpoint.product
        if (-not $byProduct.ContainsKey($prod)) {
            $byProduct[$prod] = @{ total = 0; covered = 0; missing = 0 }
        }
        $byProduct[$prod].total++
    }
    foreach ($ep in $covered) {
        if ($byProduct.ContainsKey($ep.product)) {
            $byProduct[$ep.product].covered++
        }
    }
    foreach ($gap in $gaps) {
        if ($byProduct.ContainsKey($gap.product)) {
            $byProduct[$gap.product].missing++
        }
    }

    # Group by priority
    $byPriority = @{
        high   = ($gaps | Where-Object { $_.priority -eq 'high' }).Count
        medium = ($gaps | Where-Object { $_.priority -eq 'medium' }).Count
        low    = ($gaps | Where-Object { $_.priority -eq 'low' }).Count
    }

    # Build report
    $report = [ordered]@{
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        summary     = [ordered]@{
            totalEndpoints   = $totalEndpoints
            covered          = $coveredCount
            missing          = $missingCount
            coveragePercent  = $coveragePercent
            deprecatedSkipped = $skipped.Count
            previouslyProcessed = ($gaps | Where-Object { $_.previouslyProcessed }).Count
            newGaps          = ($gaps | Where-Object { -not $_.previouslyProcessed }).Count
        }
        byPriority  = $byPriority
        byProduct   = $byProduct
        byCategory  = $byCategory
        gaps        = $gaps | Sort-Object @{Expression = {
            switch ($_.priority) {
                'high'   { 1 }
                'medium' { 2 }
                'low'    { 3 }
                default  { 4 }
            }
        }}, product, category, endpoint
    }

    # Save report
    $report | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputPath -Encoding UTF8

    # Summary output
    Write-Host "`nCoverage Gap Report:" -ForegroundColor Cyan
    Write-Host "  Total Endpoints: $totalEndpoints" -ForegroundColor Gray
    Write-Host "  Covered: $coveredCount ($coveragePercent%)" -ForegroundColor Green
    Write-Host "  Missing: $missingCount" -ForegroundColor Yellow
    Write-Host "  Deprecated (skipped): $($skipped.Count)" -ForegroundColor DarkGray

    Write-Host "`nGaps by Priority:" -ForegroundColor Cyan
    Write-Host "  High:   $($byPriority.high)" -ForegroundColor Red
    Write-Host "  Medium: $($byPriority.medium)" -ForegroundColor Yellow
    Write-Host "  Low:    $($byPriority.low)" -ForegroundColor DarkGray

    Write-Host "`nTop Products with Gaps:" -ForegroundColor Cyan
    $byProduct.GetEnumerator() | Sort-Object { $_.Value.missing } -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value.missing) missing / $($_.Value.total) total" -ForegroundColor Gray
    }

    Write-Host "`nOutput: $OutputPath" -ForegroundColor Gray

    return [PSCustomObject]$report
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-GetApiCoverageGaps -EndpointsPath $EndpointsPath -CoveragePath $CoveragePath -OutputPath $OutputPath -ProcessedPath $ProcessedPath
}
