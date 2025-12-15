<#
.SYNOPSIS
    Analyzes existing PSZoom cmdlets and extracts their API endpoint mappings.

.DESCRIPTION
    Scans all PSZoom public cmdlets and extracts URI patterns, HTTP methods,
    and parameter information to create a coverage map of which Zoom API
    endpoints are currently implemented.

.PARAMETER ModulePath
    Path to the PSZoom module. Defaults to PSZoom/Public relative to repo root.

.PARAMETER OutputPath
    Path for the coverage JSON file. Defaults to data/pszoom-coverage.json.

.EXAMPLE
    .\Get-PSZoomCoverage.ps1
    Analyzes PSZoom cmdlets and outputs coverage to data/pszoom-coverage.json

.OUTPUTS
    PSCustomObject containing cmdlet coverage information.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$ModulePath,

    [Parameter()]
    [string]$OutputPath
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

function Get-CmdletEndpointInfo {
    <#
    .SYNOPSIS
        Extracts endpoint information from a PSZoom cmdlet file.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    $content = Get-Content -Path $FilePath -Raw
    $fileName = Split-Path $FilePath -Leaf
    $cmdletName = $fileName -replace '\.ps1$', ''

    $result = @{
        name       = $cmdletName
        file       = $FilePath
        endpoints  = @()
        parameters = @()
        aliases    = @()
    }

    # Extract function name (might differ from filename)
    if ($content -match 'function\s+([\w-]+)') {
        $result.functionName = $Matches[1]
    }

    # Extract aliases from [Alias()] attribute
    $aliasMatches = [regex]::Matches($content, '\[Alias\([''"]([^''"]+)[''"]\)\]')
    foreach ($match in $aliasMatches) {
        $result.aliases += $match.Groups[1].Value
    }

    # Extract URI patterns - various patterns used in PSZoom
    $uriPatterns = @()

    # Pattern 1: $baseURI = "https://api.$ZoomURI/v2/..."
    $baseUriMatches = [regex]::Matches($content, '\$baseURI\s*=\s*[''"]https://api\.\$ZoomURI(/v2[^''"]+)[''"]')
    foreach ($match in $baseUriMatches) {
        $uriPatterns += $match.Groups[1].Value
    }

    # Pattern 2: Direct URI in Invoke-ZoomRestMethod
    $invokeMatches = [regex]::Matches($content, 'Invoke-ZoomRestMethod\s+-Uri\s*[''"]https://api\.\$ZoomURI(/v2[^''"]+)[''"]')
    foreach ($match in $invokeMatches) {
        $uriPatterns += $match.Groups[1].Value
    }

    # Pattern 3: [System.UriBuilder]::new construction
    $uriBuilderMatches = [regex]::Matches($content, '\[System\.UriBuilder\]::new\([^)]*,\s*[''"]([^''"]+)[''"]')
    foreach ($match in $uriBuilderMatches) {
        $path = $match.Groups[1].Value
        if ($path -notmatch '^/v2') {
            $path = "/v2$path"
        }
        $uriPatterns += $path
    }

    # Pattern 4: [System.UriBuilder]"https://api.$ZoomURI/v2/..." (direct cast)
    $uriBuilderCastMatches = [regex]::Matches($content, '\[System\.UriBuilder\][''"]https://api\.\$ZoomURI(/v2[^''"]+)[''"]')
    foreach ($match in $uriBuilderCastMatches) {
        $uriPatterns += $match.Groups[1].Value
    }

    # Pattern 5: $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/..."
    $requestAssignMatches = [regex]::Matches($content, '\$\w+\s*=\s*\[System\.UriBuilder\][''"]https://api\.\$ZoomURI(/v2[^''"]+)[''"]')
    foreach ($match in $requestAssignMatches) {
        $uriPatterns += $match.Groups[1].Value
    }

    # Pattern 6: $Request.Path assignments
    $pathMatches = [regex]::Matches($content, '\$Request\.Path\s*=\s*[''"]([^''"]+)[''"]')
    foreach ($match in $pathMatches) {
        $path = $match.Groups[1].Value
        if ($path -notmatch '^/v2') {
            $path = "/v2$path"
        }
        $uriPatterns += $path
    }

    # Pattern 5: String concatenation with $baseURI
    # e.g., "{0}{1}/" -f $baseURI,$id
    if ($content -match '\$baseURIplus\w+\s*=\s*[''"]?\{0\}\{1\}') {
        # Has dynamic path extension - mark with placeholder
    }

    # Normalize URI patterns - replace variable interpolations with placeholders
    $normalizedUris = @()
    foreach ($uri in $uriPatterns) {
        # Replace common variable patterns with standard placeholders
        $normalized = $uri `
            -replace '\$UserId', '{userId}' `
            -replace '\$MeetingId', '{meetingId}' `
            -replace '\$WebinarId', '{webinarId}' `
            -replace '\$GroupId', '{groupId}' `
            -replace '\$RoleId', '{roleId}' `
            -replace '\$AccountId', '{accountId}' `
            -replace '\$RoomId', '{roomId}' `
            -replace '\$ChannelId', '{channelId}' `
            -replace '\$MessageId', '{messageId}' `
            -replace '\$ContactId', '{contactId}' `
            -replace '\$RecordingId', '{recordingId}' `
            -replace '\$ReportId', '{reportId}' `
            -replace '\$id', '{id}' `
            -replace '\$\w+Id', '{id}' `
            -replace '/\$\w+/', '/{id}/' `
            -replace '/\$\w+$', '/{id}' `
            -replace '\$\{[^}]+\}', '{id}' `
            -replace '//+', '/' `
            -replace '/$', ''

        if ($normalized -notin $normalizedUris) {
            $normalizedUris += $normalized
        }
    }

    # Detect HTTP method from cmdlet name or Invoke-ZoomRestMethod calls
    $httpMethod = 'GET'  # Default

    # Check cmdlet verb
    if ($cmdletName -match '^(Get|Read|Find|Search)-') {
        $httpMethod = 'GET'
    }
    elseif ($cmdletName -match '^(New|Add|Create)-') {
        $httpMethod = 'POST'
    }
    elseif ($cmdletName -match '^(Set|Update)-') {
        $httpMethod = 'PATCH'
    }
    elseif ($cmdletName -match '^(Remove|Delete)-') {
        $httpMethod = 'DELETE'
    }

    # Override with explicit method from code
    if ($content -match 'Invoke-ZoomRestMethod[^}]+-Method\s+[''"]?(GET|POST|PUT|PATCH|DELETE)[''"]?') {
        $httpMethod = $Matches[1].ToUpper()
    }

    # Also check for -Body parameter which usually indicates POST/PATCH/PUT
    if ($content -match 'Invoke-ZoomRestMethod[^}]+-Body\s+\$' -and $httpMethod -eq 'GET') {
        if ($cmdletName -match '^New-') {
            $httpMethod = 'POST'
        }
        elseif ($cmdletName -match '^(Set|Update)-') {
            $httpMethod = 'PATCH'
        }
    }

    # Build endpoint entries
    foreach ($uri in $normalizedUris) {
        $result.endpoints += @{
            path   = $uri
            method = $httpMethod
            hash   = Get-EndpointHash -Method $httpMethod -Path $uri
        }
    }

    # Extract parameters from param block
    $paramMatches = [regex]::Matches($content, '\[(?:Parameter[^\]]*)\]\s*(?:\[[^\]]+\]\s*)*\[?(?:string|int|switch|bool|array|hashtable|\w+)\[?\]?\s*\$(\w+)')
    foreach ($match in $paramMatches) {
        $paramName = $match.Groups[1].Value
        if ($paramName -notin $result.parameters) {
            $result.parameters += $paramName
        }
    }

    # Also get parameters from simple declarations
    $simpleParamMatches = [regex]::Matches($content, 'param\s*\([^)]*\$(\w+)', [System.Text.RegularExpressions.RegexOptions]::Singleline)

    return $result
}

function Get-CategoryFromPath {
    param([string]$FilePath)

    # Extract category from folder structure: PSZoom/Public/{Category}/
    if ($FilePath -match 'Public[\\/]([^\\/]+)[\\/]') {
        return $Matches[1]
    }
    return 'Other'
}

#endregion

#region Main Logic

function Invoke-GetPSZoomCoverage {
    [CmdletBinding()]
    param(
        [string]$ModulePath,
        [string]$OutputPath
    )

    # Set defaults
    $repoRoot = Get-RepoRoot

    if (-not $ModulePath) {
        $ModulePath = Join-Path $repoRoot 'PSZoom\Public'
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path $repoRoot 'data\pszoom-coverage.json'
    }

    # Validate module path
    if (-not (Test-Path $ModulePath)) {
        throw "Module path not found: $ModulePath"
    }

    # Get all cmdlet files
    $cmdletFiles = Get-ChildItem -Path $ModulePath -Filter '*.ps1' -Recurse -File

    Write-Host "Analyzing $($cmdletFiles.Count) PSZoom cmdlet files..." -ForegroundColor Cyan

    $cmdlets = @()
    $endpointMap = @{}
    $categoryStats = @{}

    foreach ($file in $cmdletFiles) {
        $relativePath = $file.FullName.Replace($repoRoot, '').TrimStart('\', '/')
        $category = Get-CategoryFromPath -FilePath $file.FullName

        Write-Host "  [SCAN] $($file.Name)..." -ForegroundColor Yellow -NoNewline

        try {
            $cmdletInfo = Get-CmdletEndpointInfo -FilePath $file.FullName
            $cmdletInfo.file = $relativePath
            $cmdletInfo.category = $category

            $cmdlets += $cmdletInfo

            # Track endpoints
            foreach ($endpoint in $cmdletInfo.endpoints) {
                $key = "$($endpoint.method)|$($endpoint.path)"
                if (-not $endpointMap.ContainsKey($key)) {
                    $endpointMap[$key] = @()
                }
                $endpointMap[$key] += $cmdletInfo.name
            }

            # Track category stats
            if (-not $categoryStats.ContainsKey($category)) {
                $categoryStats[$category] = 0
            }
            $categoryStats[$category]++

            $endpointCount = $cmdletInfo.endpoints.Count
            if ($endpointCount -gt 0) {
                Write-Host " $endpointCount endpoint(s)" -ForegroundColor Green
            }
            else {
                Write-Host " (no endpoints detected)" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Build unique endpoint list
    $uniqueEndpoints = @()
    foreach ($cmdlet in $cmdlets) {
        foreach ($endpoint in $cmdlet.endpoints) {
            $existing = $uniqueEndpoints | Where-Object { $_.hash -eq $endpoint.hash }
            if (-not $existing) {
                $uniqueEndpoints += @{
                    path     = $endpoint.path
                    method   = $endpoint.method
                    hash     = $endpoint.hash
                    cmdlets  = @($cmdlet.name)
                }
            }
            else {
                if ($cmdlet.name -notin $existing.cmdlets) {
                    $existing.cmdlets += $cmdlet.name
                }
            }
        }
    }

    # Build output
    $coverage = [ordered]@{
        analyzedAt   = (Get-Date).ToUniversalTime().ToString('o')
        modulePath   = $ModulePath
        cmdletCount  = $cmdlets.Count
        endpointCount = $uniqueEndpoints.Count
        statistics   = [ordered]@{
            byCategory     = $categoryStats
            cmdletsWithEndpoints = ($cmdlets | Where-Object { $_.endpoints.Count -gt 0 }).Count
            cmdletsWithoutEndpoints = ($cmdlets | Where-Object { $_.endpoints.Count -eq 0 }).Count
        }
        cmdlets      = $cmdlets | Sort-Object category, name
        endpoints    = $uniqueEndpoints | Sort-Object method, path
    }

    # Ensure output directory exists
    $outputDir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    # Save output
    $coverage | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputPath -Encoding UTF8

    # Summary
    Write-Host "`nPSZoom Coverage Summary:" -ForegroundColor Cyan
    Write-Host "  Total Cmdlets: $($cmdlets.Count)" -ForegroundColor Green
    Write-Host "  Unique Endpoints: $($uniqueEndpoints.Count)" -ForegroundColor Green
    Write-Host "  Output: $OutputPath" -ForegroundColor Gray

    Write-Host "`nBy Category:" -ForegroundColor Cyan
    $categoryStats.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
    }

    return [PSCustomObject]$coverage
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-GetPSZoomCoverage -ModulePath $ModulePath -OutputPath $OutputPath
}
