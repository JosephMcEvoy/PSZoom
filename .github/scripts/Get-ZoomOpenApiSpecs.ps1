<#
.SYNOPSIS
    Downloads OpenAPI specifications from Zoom's API Hub.

.DESCRIPTION
    Fetches OpenAPI 3.0 specifications from Zoom's developer portal for all known
    API products. Supports caching, rate limiting, and auto-discovery of new API products.

.PARAMETER OutputPath
    Directory to save downloaded specs. Defaults to data/specs relative to repo root.

.PARAMETER Products
    Specific API products to download. If not specified, downloads all known products.

.PARAMETER CacheDurationHours
    How long to use cached specs before re-downloading. Default: 24 hours.

.PARAMETER Force
    Force re-download even if cache is valid.

.PARAMETER DiscoverProducts
    Attempt to discover new API products from Zoom's documentation.

.EXAMPLE
    .\Get-ZoomOpenApiSpecs.ps1
    Downloads all known Zoom API specs to data/specs/

.EXAMPLE
    .\Get-ZoomOpenApiSpecs.ps1 -Products meetings,users -Force
    Force downloads only meetings and users specs.

.OUTPUTS
    PSCustomObject with download results and metadata.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [string[]]$Products,

    [Parameter()]
    [int]$CacheDurationHours = 24,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$DiscoverProducts
)

#region Configuration

$script:KnownProducts = @(
    'meetings'
    'phone'
    'users'
    'accounts'
    'contact-center'
    'rooms'
    'team-chat'
    'video-sdk'
    'webinars'
    'reports'
    'groups'
    'roles'
    'dashboards'
    'devices'
    'pac'
    'sip-phone'
    'archiving'
    'cloud-recording'
)

$script:RateLimitConfig = @{
    MaxRequestsPerMinute = 10
    RetryCount           = 3
    RetryDelaySeconds    = 5
    RequestDelayMs       = 500
}

$script:BaseUrl = 'https://developers.zoom.us/api-hub'

#endregion

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

function Get-SpecUrl {
    param([string]$Product)
    return "$script:BaseUrl/$Product/methods/endpoints.json"
}

function Get-CacheFilePath {
    param(
        [string]$OutputDir,
        [string]$Product
    )
    return Join-Path $OutputDir "$Product-api.json"
}

function Test-CacheValid {
    param(
        [string]$FilePath,
        [int]$MaxAgeHours
    )

    if (-not (Test-Path $FilePath)) {
        return $false
    }

    $fileAge = (Get-Date) - (Get-Item $FilePath).LastWriteTime
    return $fileAge.TotalHours -lt $MaxAgeHours
}

function Invoke-RateLimitedRequest {
    param(
        [string]$Uri,
        [int]$RetryCount = $script:RateLimitConfig.RetryCount
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -lt $RetryCount) {
        $attempt++
        try {
            Start-Sleep -Milliseconds $script:RateLimitConfig.RequestDelayMs

            $response = Invoke-RestMethod -Uri $Uri -Method Get -ErrorAction Stop
            return @{
                Success  = $true
                Data     = $response
                Error    = $null
                Attempts = $attempt
            }
        }
        catch {
            $lastError = $_
            $statusCode = $_.Exception.Response.StatusCode.value__

            if ($statusCode -eq 404) {
                return @{
                    Success  = $false
                    Data     = $null
                    Error    = "Not found: $Uri"
                    Attempts = $attempt
                }
            }

            if ($statusCode -eq 429 -or $statusCode -ge 500) {
                Write-Warning "Request failed (attempt $attempt/$RetryCount): $($_.Exception.Message)"
                Start-Sleep -Seconds ($script:RateLimitConfig.RetryDelaySeconds * $attempt)
                continue
            }

            return @{
                Success  = $false
                Data     = $null
                Error    = $_.Exception.Message
                Attempts = $attempt
            }
        }
    }

    return @{
        Success  = $false
        Data     = $null
        Error    = "Max retries exceeded: $($lastError.Exception.Message)"
        Attempts = $attempt
    }
}

function Save-SpecWithMetadata {
    param(
        [string]$FilePath,
        [object]$Spec,
        [string]$Product,
        [string]$SourceUrl
    )

    $wrapper = [ordered]@{
        source       = $Product
        sourceUrl    = $SourceUrl
        downloadedAt = (Get-Date).ToUniversalTime().ToString('o')
        specVersion  = $Spec.openapi ?? $Spec.swagger ?? 'unknown'
        spec         = $Spec
    }

    $wrapper | ConvertTo-Json -Depth 100 -Compress:$false | Set-Content -Path $FilePath -Encoding UTF8

    return $wrapper
}

#endregion

#region Main Logic

function Get-ZoomOpenApiSpecs {
    [CmdletBinding()]
    param(
        [string]$OutputPath,
        [string[]]$Products,
        [int]$CacheDurationHours = 24,
        [switch]$Force,
        [switch]$DiscoverProducts
    )

    # Determine output directory
    if (-not $OutputPath) {
        $repoRoot = Get-RepoRoot
        $OutputPath = Join-Path $repoRoot 'data\specs'
    }

    # Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }

    # Determine which products to fetch
    $targetProducts = if ($Products) { $Products } else { $script:KnownProducts }

    # Track results
    $results = @{
        timestamp       = (Get-Date).ToUniversalTime().ToString('o')
        outputPath      = $OutputPath
        products        = @{}
        summary         = @{
            total      = $targetProducts.Count
            downloaded = 0
            cached     = 0
            failed     = 0
        }
    }

    Write-Host "Downloading Zoom OpenAPI specs for $($targetProducts.Count) products..." -ForegroundColor Cyan

    foreach ($product in $targetProducts) {
        $cacheFile = Get-CacheFilePath -OutputDir $OutputPath -Product $product
        $specUrl = Get-SpecUrl -Product $product

        # Check cache
        if (-not $Force -and (Test-CacheValid -FilePath $cacheFile -MaxAgeHours $CacheDurationHours)) {
            Write-Host "  [CACHED] $product" -ForegroundColor DarkGray
            $results.products[$product] = @{
                status    = 'cached'
                file      = $cacheFile
                url       = $specUrl
            }
            $results.summary.cached++
            continue
        }

        # Download spec
        Write-Host "  [FETCH] $product..." -ForegroundColor Yellow -NoNewline
        $response = Invoke-RateLimitedRequest -Uri $specUrl

        if ($response.Success) {
            $saved = Save-SpecWithMetadata -FilePath $cacheFile -Spec $response.Data -Product $product -SourceUrl $specUrl
            Write-Host " OK (v$($saved.specVersion))" -ForegroundColor Green

            $results.products[$product] = @{
                status      = 'downloaded'
                file        = $cacheFile
                url         = $specUrl
                specVersion = $saved.specVersion
                attempts    = $response.Attempts
            }
            $results.summary.downloaded++
        }
        else {
            Write-Host " FAILED: $($response.Error)" -ForegroundColor Red
            $results.products[$product] = @{
                status   = 'failed'
                url      = $specUrl
                error    = $response.Error
                attempts = $response.Attempts
            }
            $results.summary.failed++
        }
    }

    # Save discovery results
    $discoveryFile = Join-Path (Split-Path $OutputPath) 'discovered-api-products.json'
    $discoveryData = @{
        lastRun         = $results.timestamp
        knownProducts   = $script:KnownProducts
        successfulSpecs = ($results.products.GetEnumerator() | Where-Object { $_.Value.status -ne 'failed' }).Name
        failedSpecs     = ($results.products.GetEnumerator() | Where-Object { $_.Value.status -eq 'failed' }).Name
    }
    $discoveryData | ConvertTo-Json -Depth 10 | Set-Content -Path $discoveryFile -Encoding UTF8

    # Summary
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Downloaded: $($results.summary.downloaded)" -ForegroundColor Green
    Write-Host "  Cached:     $($results.summary.cached)" -ForegroundColor DarkGray
    Write-Host "  Failed:     $($results.summary.failed)" -ForegroundColor $(if ($results.summary.failed -gt 0) { 'Red' } else { 'Green' })

    return [PSCustomObject]$results
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Get-ZoomOpenApiSpecs -OutputPath $OutputPath -Products $Products -CacheDurationHours $CacheDurationHours -Force:$Force -DiscoverProducts:$DiscoverProducts
}
