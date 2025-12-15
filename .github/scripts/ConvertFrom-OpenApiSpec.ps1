<#
.SYNOPSIS
    Parses OpenAPI specs and normalizes endpoints to a common format.

.DESCRIPTION
    Reads downloaded OpenAPI 2.0/3.0 specifications from the specs directory,
    extracts all endpoints, and normalizes them to a unified format for
    comparison with existing PSZoom cmdlets.

.PARAMETER SpecsPath
    Directory containing downloaded OpenAPI spec files. Defaults to data/specs.

.PARAMETER OutputPath
    Path for the normalized endpoints JSON file. Defaults to data/zoom-api-endpoints.json.

.EXAMPLE
    .\ConvertFrom-OpenApiSpec.ps1
    Parses all specs in data/specs and outputs to data/zoom-api-endpoints.json

.OUTPUTS
    PSCustomObject containing normalized endpoint registry.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$SpecsPath,

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

function ConvertFrom-OpenApi3Parameter {
    param([object]$Parameter)

    $normalized = @{
        name        = $Parameter.name
        in          = $Parameter.in
        required    = $Parameter.required -eq $true
        description = $Parameter.description ?? ''
    }

    # Handle schema
    if ($Parameter.schema) {
        $normalized.type = $Parameter.schema.type ?? 'string'
        $normalized.format = $Parameter.schema.format
        $normalized.enum = $Parameter.schema.enum
        $normalized.default = $Parameter.schema.default
    }
    else {
        $normalized.type = $Parameter.type ?? 'string'
    }

    return $normalized
}

function ConvertFrom-OpenApi2Parameter {
    param([object]$Parameter)

    return @{
        name        = $Parameter.name
        in          = $Parameter.in
        required    = $Parameter.required -eq $true
        description = $Parameter.description ?? ''
        type        = $Parameter.type ?? 'string'
        format      = $Parameter.format
        enum        = $Parameter.enum
        default     = $Parameter.default
    }
}

function Get-RequestBodyParameters {
    param([object]$RequestBody)

    $params = @()

    if (-not $RequestBody -or -not $RequestBody.content) {
        return $params
    }

    $jsonContent = $RequestBody.content.'application/json'
    if (-not $jsonContent -or -not $jsonContent.schema) {
        return $params
    }

    $schema = $jsonContent.schema

    # Handle properties in schema
    if ($schema.properties) {
        foreach ($propName in $schema.properties.PSObject.Properties.Name) {
            $prop = $schema.properties.$propName
            $isRequired = $schema.required -and $schema.required -contains $propName

            $params += @{
                name        = $propName
                in          = 'body'
                required    = $isRequired
                description = $prop.description ?? ''
                type        = $prop.type ?? 'object'
                format      = $prop.format
                enum        = $prop.enum
            }
        }
    }

    return $params
}

function Get-ResponseSchema {
    param([object]$Responses)

    if (-not $Responses) { return $null }

    # Look for 200/201/204 responses
    $successResponse = $Responses.'200' ?? $Responses.'201' ?? $Responses.'204'
    if (-not $successResponse) { return $null }

    # OpenAPI 3.0 style
    if ($successResponse.content) {
        $jsonContent = $successResponse.content.'application/json'
        if ($jsonContent -and $jsonContent.schema) {
            return $jsonContent.schema
        }
    }

    # OpenAPI 2.0 style
    if ($successResponse.schema) {
        return $successResponse.schema
    }

    return $null
}

function Get-EndpointScopes {
    param([object]$Security)

    $scopes = @()

    if (-not $Security) { return $scopes }

    foreach ($secReq in $Security) {
        foreach ($scheme in $secReq.PSObject.Properties) {
            if ($scheme.Value -is [array]) {
                $scopes += $scheme.Value
            }
        }
    }

    return $scopes | Select-Object -Unique
}

function ConvertFrom-OpenApiSpec {
    param(
        [Parameter(Mandatory)]
        [object]$Spec,

        [Parameter(Mandatory)]
        [string]$Product
    )

    $endpoints = @()
    $specVersion = $Spec.openapi ?? $Spec.swagger ?? 'unknown'
    $isOpenApi3 = $specVersion -match '^3\.'

    # Get paths
    $paths = $Spec.paths
    if (-not $paths) {
        Write-Warning "No paths found in spec for $Product"
        return $endpoints
    }

    foreach ($pathProp in $paths.PSObject.Properties) {
        $path = $pathProp.Name
        $pathItem = $pathProp.Value

        # Skip if not a path item (could be $ref, etc.)
        if ($path.StartsWith('$')) { continue }

        # Common parameters for all operations on this path
        $commonParams = @()
        if ($pathItem.parameters) {
            foreach ($param in $pathItem.parameters) {
                if ($isOpenApi3) {
                    $commonParams += ConvertFrom-OpenApi3Parameter -Parameter $param
                }
                else {
                    $commonParams += ConvertFrom-OpenApi2Parameter -Parameter $param
                }
            }
        }

        # Process each HTTP method
        $httpMethods = @('get', 'post', 'put', 'patch', 'delete', 'head', 'options')

        foreach ($method in $httpMethods) {
            $operation = $pathItem.$method
            if (-not $operation) { continue }

            # Collect parameters
            $allParams = @() + $commonParams

            if ($operation.parameters) {
                foreach ($param in $operation.parameters) {
                    if ($isOpenApi3) {
                        $allParams += ConvertFrom-OpenApi3Parameter -Parameter $param
                    }
                    else {
                        $allParams += ConvertFrom-OpenApi2Parameter -Parameter $param
                    }
                }
            }

            # Get request body params (OpenAPI 3.0)
            if ($isOpenApi3 -and $operation.requestBody) {
                $allParams += Get-RequestBodyParameters -RequestBody $operation.requestBody
            }

            # Get body params (OpenAPI 2.0)
            if (-not $isOpenApi3 -and $operation.parameters) {
                $bodyParams = $operation.parameters | Where-Object { $_.in -eq 'body' }
                foreach ($bodyParam in $bodyParams) {
                    if ($bodyParam.schema -and $bodyParam.schema.properties) {
                        foreach ($propName in $bodyParam.schema.properties.PSObject.Properties.Name) {
                            $prop = $bodyParam.schema.properties.$propName
                            $allParams += @{
                                name        = $propName
                                in          = 'body'
                                required    = $bodyParam.schema.required -and $bodyParam.schema.required -contains $propName
                                description = $prop.description ?? ''
                                type        = $prop.type ?? 'object'
                            }
                        }
                    }
                }
            }

            # Normalize path - ensure it starts with /v2
            $normalizedPath = $path
            if (-not $normalizedPath.StartsWith('/v2')) {
                $normalizedPath = "/v2$normalizedPath"
            }

            # Determine category from tags or path
            $category = 'other'
            if ($operation.tags -and $operation.tags.Count -gt 0) {
                $category = $operation.tags[0].ToLower() -replace '\s+', '-'
            }
            elseif ($normalizedPath -match '^/v2/([^/]+)') {
                $category = $Matches[1].ToLower()
            }

            # Build endpoint object as PSCustomObject for proper Group-Object support
            $endpoint = [PSCustomObject]@{
                id            = Get-EndpointHash -Method $method -Path $normalizedPath
                path          = $normalizedPath
                method        = $method.ToUpper()
                product       = $Product
                category      = $category
                operationId   = $operation.operationId ?? ''
                summary       = $operation.summary ?? ''
                description   = $operation.description ?? ''
                parameters    = $allParams
                scopes        = Get-EndpointScopes -Security $operation.security
                deprecated    = $operation.deprecated -eq $true
                responseSchema = Get-ResponseSchema -Responses $operation.responses
            }

            $endpoints += $endpoint
        }
    }

    return $endpoints
}

#endregion

#region Main Logic

function Invoke-ConvertFromOpenApiSpec {
    [CmdletBinding()]
    param(
        [string]$SpecsPath,
        [string]$OutputPath
    )

    # Set defaults
    $repoRoot = Get-RepoRoot

    if (-not $SpecsPath) {
        $SpecsPath = Join-Path $repoRoot 'data\specs'
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path $repoRoot 'data\zoom-api-endpoints.json'
    }

    # Validate specs directory
    if (-not (Test-Path $SpecsPath)) {
        throw "Specs directory not found: $SpecsPath. Run Get-ZoomOpenApiSpecs.ps1 first."
    }

    # Get all spec files
    $specFiles = Get-ChildItem -Path $SpecsPath -Filter '*-api.json' -File

    if ($specFiles.Count -eq 0) {
        throw "No spec files found in $SpecsPath. Run Get-ZoomOpenApiSpecs.ps1 first."
    }

    Write-Host "Parsing $($specFiles.Count) OpenAPI spec files..." -ForegroundColor Cyan

    $allEndpoints = @()
    $sources = @()
    $productStats = @{}

    foreach ($specFile in $specFiles) {
        $product = $specFile.BaseName -replace '-api$', ''

        Write-Host "  [PARSE] $product..." -ForegroundColor Yellow -NoNewline

        try {
            $specData = Get-Content -Path $specFile.FullName -Raw | ConvertFrom-Json

            # The actual spec is nested under 'spec' key from our download wrapper
            $spec = if ($specData.spec) { $specData.spec } else { $specData }

            $endpoints = ConvertFrom-OpenApiSpec -Spec $spec -Product $product
            $allEndpoints += $endpoints
            $sources += $product

            $productStats[$product] = $endpoints.Count
            Write-Host " $($endpoints.Count) endpoints" -ForegroundColor Green
        }
        catch {
            Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
            $productStats[$product] = 0
        }
    }

    # Remove duplicates (same endpoint might appear in multiple specs)
    $uniqueEndpoints = $allEndpoints | Group-Object -Property id | ForEach-Object {
        $_.Group[0]
    }

    # Build output
    $registry = [ordered]@{
        version     = (Get-Date).ToString('yyyy-MM-dd')
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        sources     = $sources | Sort-Object
        statistics  = [ordered]@{
            totalEndpoints  = $uniqueEndpoints.Count
            byProduct       = $productStats
            byMethod        = ($uniqueEndpoints | Group-Object method | ForEach-Object { @{ $_.Name = $_.Count } })
            byCategory      = ($uniqueEndpoints | Group-Object category | Sort-Object Count -Descending | Select-Object -First 20 | ForEach-Object { @{ $_.Name = $_.Count } })
            deprecatedCount = ($uniqueEndpoints | Where-Object { $_.deprecated }).Count
        }
        endpoints   = $uniqueEndpoints | Sort-Object product, category, path, method
    }

    # Ensure output directory exists
    $outputDir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    # Save output
    $registry | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputPath -Encoding UTF8

    # Summary
    Write-Host "`nEndpoint Registry Summary:" -ForegroundColor Cyan
    Write-Host "  Total Endpoints: $($uniqueEndpoints.Count)" -ForegroundColor Green
    Write-Host "  Sources: $($sources -join ', ')" -ForegroundColor Gray
    Write-Host "  Output: $OutputPath" -ForegroundColor Gray

    Write-Host "`nBy Method:" -ForegroundColor Cyan
    $uniqueEndpoints | Group-Object method | Sort-Object Count -Descending | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor Gray
    }

    return [PSCustomObject]$registry
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-ConvertFromOpenApiSpec -SpecsPath $SpecsPath -OutputPath $OutputPath
}
