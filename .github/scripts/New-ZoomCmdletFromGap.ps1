<#
.SYNOPSIS
    Generates PSZoom cmdlets from API coverage gaps using Claude CLI.

.DESCRIPTION
    Takes gap entries from the coverage gap report and generates cmdlet code,
    unit tests, and mock response fixtures using the Claude CLI (claude command).
    Uses your authenticated Claude account - no API key needed.
    Follows existing PSZoom patterns and conventions.

.PARAMETER GapReportPath
    Path to coverage-gap-report.json. Defaults to data/coverage-gap-report.json.

.PARAMETER MaxCmdlets
    Maximum number of cmdlets to generate per run. Default: 10.

.PARAMETER Priority
    Filter gaps by priority: 'high', 'medium', 'low', or 'all'. Default: 'high'.

.PARAMETER DryRun
    Generate prompts and preview output without writing files.

.PARAMETER SkipProcessed
    Skip endpoints that have been previously processed. Default: $true.

.EXAMPLE
    .\New-ZoomCmdletFromGap.ps1 -MaxCmdlets 5 -Priority high
    Generates up to 5 high-priority cmdlets.

.EXAMPLE
    .\New-ZoomCmdletFromGap.ps1 -DryRun -MaxCmdlets 1
    Preview generation for 1 cmdlet without writing files.

.OUTPUTS
    PSCustomObject containing generation results and statistics.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$GapReportPath,

    [Parameter()]
    [int]$MaxCmdlets = 10,

    [Parameter()]
    [ValidateSet('high', 'medium', 'low', 'all')]
    [string]$Priority = 'high',

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$SkipProcessed = $true
)

#region Configuration

$script:Config = @{
    MaxTokens = 16000
}

#endregion

#region Helper Functions

function Get-RepoRoot {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return $gitRoot -replace '/', '\'
    }
    return $PSScriptRoot | Split-Path | Split-Path
}

function Get-VerbFromMethod {
    param([string]$Method)

    switch ($Method.ToUpper()) {
        'GET'    { 'Get' }
        'POST'   { 'New' }
        'PUT'    { 'Set' }
        'PATCH'  { 'Update' }
        'DELETE' { 'Remove' }
        default  { 'Invoke' }
    }
}

function Get-CategoryFolder {
    param([string]$Category)

    # Map API categories to PSZoom folder structure
    $categoryMap = @{
        'meetings'        = 'Meetings'
        'users'           = 'Users'
        'webinars'        = 'Webinars'
        'phone'           = 'Phone'
        'groups'          = 'Groups'
        'accounts'        = 'Account'
        'rooms'           = 'Rooms'
        'reports'         = 'Reports'
        'archiving'       = 'CloudRecording'
        'cloud-recording' = 'CloudRecording'
        'team-chat'       = 'TeamChat'
        'contact-center'  = 'ContactCenter'
        'im'              = 'IMChat'
        'im-groups'       = 'IMGroups'
        'tracking-fields' = 'TrackingFields'
        'devices'         = 'Devices'
        'dashboards'      = 'Dashboards'
        'pac'             = 'PAC'
    }

    # Check for phone subcategories
    $phoneCategories = @(
        'auto-receptionists', 'blocked-list', 'call-handling', 'call-logs',
        'call-queues', 'common-areas', 'devices', 'external-contacts',
        'phone-numbers', 'recordings', 'shared-line-groups', 'sms',
        'users', 'voicemails', 'sites', 'emergency-addresses',
        'shared-line-appearance', 'provision-templates', 'calling-plans'
    )

    if ($phoneCategories -contains $Category.ToLower()) {
        return 'Phone'
    }

    if ($categoryMap.ContainsKey($Category.ToLower())) {
        return $categoryMap[$Category.ToLower()]
    }

    # Default: PascalCase the category
    return (Get-Culture).TextInfo.ToTitleCase($Category.ToLower()) -replace '-', ''
}

function Get-CmdletPrompt {
    param(
        [Parameter(Mandatory)]
        [object]$Gap,

        [Parameter(Mandatory)]
        [string]$ReferenceCode
    )

    $method = $Gap.method
    $path = $Gap.endpoint
    $verb = Get-VerbFromMethod -Method $method
    $suggestedName = $Gap.suggestedCmdletName

    # Build parameter info
    $paramInfo = if ($Gap.parameters -and $Gap.parameters.Count -gt 0) {
        ($Gap.parameters | ForEach-Object {
            $required = if ($_.required) { 'Required' } else { 'Optional' }
            "- $($_.name) ($($_.type), $required, in: $($_.in)): $($_.description)"
        }) -join "`n"
    } else {
        "No parameters documented."
    }

    $prompt = @"
You are a PowerShell expert generating cmdlets for PSZoom, a PowerShell module for the Zoom API.

## TASK
Generate a complete PowerShell cmdlet implementation for this Zoom API endpoint:

**Endpoint:** $method $path
**Suggested Name:** $suggestedName
**Summary:** $($Gap.summary)
**Description:** $($Gap.description)

**Parameters:**
$paramInfo

## REQUIREMENTS

1. **Naming:** Use Verb-ZoomNoun format with approved PowerShell verbs ($verb-Zoom...)
2. **Comment-Based Help:** Include .SYNOPSIS, .DESCRIPTION, .PARAMETER (for each), .EXAMPLE (2-3), .LINK, .OUTPUTS
3. **Pipeline Support:** Add ValueFromPipeline and ValueFromPipelineByPropertyName where appropriate
4. **Parameter Aliases:** Add [Alias()] matching Zoom API field names (e.g., user_id for UserId)
5. **URL Construction:** Use [System.UriBuilder] pattern: `$`Request = [System.UriBuilder]"https://api.`$ZoomURI/v2/..."`
6. **API Call:** Use Invoke-ZoomRestMethod -Uri `$Request.Uri -Method $method [-Body `$RequestBody]
7. **Query Parameters:** Use [System.Web.HttpUtility]::ParseQueryString for query string params
8. **Request Body:** Build hashtable and use ConvertTo-Json -Depth 10 for POST/PATCH/PUT
9. **Output:** Use Write-Output `$response

## REFERENCE PATTERN
Here's an existing cmdlet to follow as a pattern:

``````powershell
$ReferenceCode
``````

## OUTPUT FORMAT
Return ONLY the PowerShell code for the cmdlet file. No markdown code blocks, no explanations.
Start directly with the comment-based help block (<#) and end with the closing brace of the function.
"@

    return $prompt
}

function Get-TestPrompt {
    param(
        [Parameter(Mandatory)]
        [object]$Gap,

        [Parameter(Mandatory)]
        [string]$CmdletCode,

        [Parameter(Mandatory)]
        [string]$CmdletName
    )

    $prompt = @"
You are a PowerShell expert generating Pester tests for PSZoom cmdlets.

## TASK
Generate a complete Pester 5 test file for this PSZoom cmdlet:

**Cmdlet Name:** $CmdletName
**Endpoint:** $($Gap.method) $($Gap.endpoint)

## CMDLET CODE
``````powershell
$CmdletCode
``````

## REQUIREMENTS

1. **Pester 5 Syntax:** Use BeforeAll, Describe, Context, It blocks
2. **Module Import:** In BeforeAll, import from `$`PSScriptRoot/../../../../PSZoom/PSZoom.psd1
3. **Mock Setup:** Set `$`script:PSZoomToken and `$`script:ZoomURI in BeforeAll
4. **Mock Fixture:** Load from `$`PSScriptRoot/../../../Fixtures/MockResponses/{filename}.json
5. **Mock API Calls:** Mock Invoke-ZoomRestMethod -ModuleName PSZoom
6. **Test Categories:**
   - Basic functionality (returns data)
   - API endpoint construction (correct URL pattern)
   - Parameter validation (required params, aliases)
   - Pipeline support if applicable
   - Error handling

## OUTPUT FORMAT
Return ONLY the PowerShell test code. No markdown code blocks, no explanations.
Start directly with BeforeAll { and end with the closing brace.
"@

    return $prompt
}

function Get-MockResponsePrompt {
    param(
        [Parameter(Mandatory)]
        [object]$Gap
    )

    $prompt = @"
You are generating a mock JSON response for a Zoom API endpoint for testing purposes.

## ENDPOINT
**Method:** $($Gap.method)
**Path:** $($Gap.endpoint)
**Summary:** $($Gap.summary)

## REQUIREMENTS
1. Generate realistic but fake test data
2. Include all fields that would typically be in the response
3. Use appropriate data types (strings, numbers, booleans, nested objects)
4. For IDs, use realistic format (like "KDcuGIm1QgePTO8WbOqwIQ" for user IDs)
5. For dates, use ISO 8601 format
6. For URLs, use https://zoom.us/... patterns

## OUTPUT FORMAT
Return ONLY valid JSON. No markdown code blocks, no explanations.
"@

    return $prompt
}

function Invoke-ClaudeCLI {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$SystemPrompt = 'You are a PowerShell expert specializing in Zoom API integration.'
    )

    # Determine which method to use: API key (CI) or CLI (local)
    $apiKey = $env:ANTHROPIC_API_KEY
    $hasClaudeCLI = Get-Command 'claude' -ErrorAction SilentlyContinue

    if ($apiKey) {
        # Use Anthropic API (for GitHub Actions / CI)
        return Invoke-ClaudeAPI -Prompt $Prompt -SystemPrompt $SystemPrompt -ApiKey $apiKey
    }
    elseif ($hasClaudeCLI) {
        # Use Claude CLI (for local development)
        return Invoke-ClaudeCLILocal -Prompt $Prompt -SystemPrompt $SystemPrompt
    }
    else {
        throw "No Claude access available. Either set ANTHROPIC_API_KEY environment variable or install Claude CLI."
    }
}

function Invoke-ClaudeAPI {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$SystemPrompt,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    $body = @{
        model       = 'claude-sonnet-4-20250514'
        max_tokens  = 8192
        temperature = 0.2
        messages    = @(
            @{
                role    = 'user'
                content = $Prompt
            }
        )
    }

    if ($SystemPrompt) {
        $body.system = $SystemPrompt
    }

    $headers = @{
        'x-api-key'         = $ApiKey
        'anthropic-version' = '2023-06-01'
        'content-type'      = 'application/json'
    }

    try {
        $response = Invoke-RestMethod -Uri 'https://api.anthropic.com/v1/messages' `
            -Method Post `
            -Headers $headers `
            -Body ($body | ConvertTo-Json -Depth 10)

        return $response.content[0].text
    }
    catch {
        Write-Error "Claude API call failed: $($_.Exception.Message)"
        throw
    }
}

function Invoke-ClaudeCLILocal {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$SystemPrompt
    )

    # Combine system prompt and user prompt
    $fullPrompt = @"
$SystemPrompt

$Prompt
"@

    # Use -p flag for prompt input (cleaner than piping on Windows)
    # --output-format text ensures we get just the text response
    try {
        $result = & claude -p $fullPrompt --dangerously-skip-permissions --output-format text 2>$null

        if ($LASTEXITCODE -ne 0) {
            throw "Claude CLI failed with exit code $LASTEXITCODE"
        }

        # Join array output if needed
        if ($result -is [array]) {
            $result = $result -join "`n"
        }

        # Filter out any CLI status messages that might slip through
        # Status messages like "Error: Reached max turns" should be caught
        if ($result -match '^Error:' -or $result -match '^Warning:') {
            throw "Claude CLI returned an error: $result"
        }

        return $result
    }
    catch {
        throw "Claude CLI error: $($_.Exception.Message)"
    }
}

function Test-PowerShellSyntax {
    param([string]$Code)

    try {
        $null = [System.Management.Automation.Language.Parser]::ParseInput(
            $Code,
            [ref]$null,
            [ref]$null
        )
        return $true
    }
    catch {
        return $false
    }
}

function Test-JsonSyntax {
    param([string]$Json)

    try {
        $null = $Json | ConvertFrom-Json
        return $true
    }
    catch {
        return $false
    }
}

#endregion

#region Main Logic

function New-ZoomCmdletFromGap {
    [CmdletBinding()]
    param(
        [string]$GapReportPath,
        [int]$MaxCmdlets = 10,
        [string]$Priority = 'high',
        [switch]$DryRun,
        [switch]$SkipProcessed = $true
    )

    # Set defaults
    $repoRoot = Get-RepoRoot
    $dataDir = Join-Path $repoRoot 'data'

    if (-not $GapReportPath) {
        $GapReportPath = Join-Path $dataDir 'coverage-gap-report.json'
    }

    # Validate
    if (-not (Test-Path $GapReportPath)) {
        throw "Gap report not found: $GapReportPath. Run Get-ApiCoverageGaps.ps1 first."
    }

    # Check for Claude access (either API key or CLI)
    $hasApiKey = -not [string]::IsNullOrEmpty($env:ANTHROPIC_API_KEY)
    $hasClaudeCLI = Get-Command 'claude' -ErrorAction SilentlyContinue

    if (-not $hasApiKey -and -not $hasClaudeCLI) {
        throw "No Claude access available. Either set ANTHROPIC_API_KEY environment variable or install Claude CLI."
    }

    if ($hasApiKey) {
        Write-Host "Using Anthropic API for generation" -ForegroundColor Cyan
    } else {
        Write-Host "Using Claude CLI for generation" -ForegroundColor Cyan
    }

    # Load gap report
    $gapReport = Get-Content -Path $GapReportPath -Raw | ConvertFrom-Json

    # Filter gaps
    $gaps = $gapReport.gaps
    if ($Priority -ne 'all') {
        $gaps = $gaps | Where-Object { $_.priority -eq $Priority }
    }

    if ($SkipProcessed) {
        $gaps = $gaps | Where-Object { -not $_.previouslyProcessed }
    }

    $gaps = $gaps | Select-Object -First $MaxCmdlets

    if ($gaps.Count -eq 0) {
        Write-Host "No gaps matching criteria found." -ForegroundColor Yellow
        return
    }

    Write-Host "Generating $($gaps.Count) cmdlets..." -ForegroundColor Cyan

    # Load reference code
    $referenceGetPath = Join-Path $repoRoot 'PSZoom\Public\Meetings\Get-ZoomMeeting.ps1'
    $referencePostPath = Join-Path $repoRoot 'PSZoom\Public\Users\New-ZoomUser.ps1'

    $referenceGet = Get-Content -Path $referenceGetPath -Raw
    $referencePost = Get-Content -Path $referencePostPath -Raw

    # Track results
    $results = @{
        timestamp  = (Get-Date).ToUniversalTime().ToString('o')
        generated  = @()
        failed     = @()
        skipped    = @()
    }

    # Process each gap
    foreach ($gap in $gaps) {
        $cmdletName = $gap.suggestedCmdletName
        $category = Get-CategoryFolder -Category $gap.category

        Write-Host "  [$($gap.method)] $cmdletName..." -ForegroundColor Yellow -NoNewline

        if ($DryRun) {
            Write-Host " [DRY RUN]" -ForegroundColor Magenta
            $results.skipped += @{
                hash       = $gap.hash
                cmdletName = $cmdletName
                reason     = 'dry-run'
            }
            continue
        }

        try {
            # Select reference based on method
            $reference = if ($gap.method -eq 'GET') { $referenceGet } else { $referencePost }

            # Generate cmdlet
            $cmdletPrompt = Get-CmdletPrompt -Gap $gap -ReferenceCode $reference
            $cmdletCode = Invoke-ClaudeCLI -Prompt $cmdletPrompt

            # Clean up response (remove markdown if present)
            $cmdletCode = $cmdletCode -replace '^```powershell\s*', '' -replace '\s*```$', ''
            $cmdletCode = $cmdletCode.Trim()

            # Validate syntax
            if (-not (Test-PowerShellSyntax -Code $cmdletCode)) {
                throw "Generated code has syntax errors"
            }

            # Generate test
            $testPrompt = Get-TestPrompt -Gap $gap -CmdletCode $cmdletCode -CmdletName $cmdletName
            $testCode = Invoke-ClaudeCLI -Prompt $testPrompt

            $testCode = $testCode -replace '^```powershell\s*', '' -replace '\s*```$', ''
            $testCode = $testCode.Trim()

            if (-not (Test-PowerShellSyntax -Code $testCode)) {
                Write-Warning "Test code has syntax errors, continuing anyway"
            }

            # Generate mock response
            $mockPrompt = Get-MockResponsePrompt -Gap $gap
            $mockJson = Invoke-ClaudeCLI -Prompt $mockPrompt

            $mockJson = $mockJson -replace '^```json\s*', '' -replace '\s*```$', ''
            $mockJson = $mockJson.Trim()

            if (-not (Test-JsonSyntax -Json $mockJson)) {
                Write-Warning "Mock JSON has syntax errors, continuing anyway"
            }

            # Determine file paths
            $cmdletDir = Join-Path $repoRoot "PSZoom\Public\$category"
            $testDir = Join-Path $repoRoot "Tests\Unit\Public\$category"
            $fixtureDir = Join-Path $repoRoot "Tests\Fixtures\MockResponses"

            # Ensure directories exist
            foreach ($dir in @($cmdletDir, $testDir, $fixtureDir)) {
                if (-not (Test-Path $dir)) {
                    New-Item -Path $dir -ItemType Directory -Force | Out-Null
                }
            }

            # Derive fixture filename from cmdlet name
            $fixtureName = ($cmdletName -replace '^(Get|New|Update|Remove|Set)-Zoom', '').ToLower()
            $fixtureName = $fixtureName -replace '([A-Z])', '-$1' -replace '^-', ''
            $fixtureName = "$fixtureName-$($gap.method.ToLower()).json"

            $cmdletPath = Join-Path $cmdletDir "$cmdletName.ps1"
            $testPath = Join-Path $testDir "$cmdletName.Tests.ps1"
            $fixturePath = Join-Path $fixtureDir $fixtureName

            # Write files
            Set-Content -Path $cmdletPath -Value $cmdletCode -Encoding UTF8
            Set-Content -Path $testPath -Value $testCode -Encoding UTF8
            Set-Content -Path $fixturePath -Value $mockJson -Encoding UTF8

            Write-Host " OK" -ForegroundColor Green

            $results.generated += @{
                hash         = $gap.hash
                cmdletName   = $cmdletName
                cmdletPath   = $cmdletPath -replace [regex]::Escape($repoRoot), ''
                testPath     = $testPath -replace [regex]::Escape($repoRoot), ''
                fixturePath  = $fixturePath -replace [regex]::Escape($repoRoot), ''
            }

            # Track as processed
            $processedScript = Join-Path $PSScriptRoot 'Add-ProcessedEndpoint.ps1'
            & $processedScript -EndpointHash $gap.hash -Endpoint $gap.endpoint -Method $gap.method -Result 'success' -CmdletName $cmdletName

        }
        catch {
            Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red

            $results.failed += @{
                hash       = $gap.hash
                cmdletName = $cmdletName
                error      = $_.Exception.Message
            }

            # Track as failed
            $processedScript = Join-Path $PSScriptRoot 'Add-ProcessedEndpoint.ps1'
            & $processedScript -EndpointHash $gap.hash -Endpoint $gap.endpoint -Method $gap.method -Result 'failed' -ErrorMessage $_.Exception.Message
        }

        # Rate limiting
        Start-Sleep -Seconds 2
    }

    # Summary
    Write-Host "`nGeneration Summary:" -ForegroundColor Cyan
    Write-Host "  Generated: $($results.generated.Count)" -ForegroundColor Green
    Write-Host "  Failed:    $($results.failed.Count)" -ForegroundColor $(if ($results.failed.Count -gt 0) { 'Red' } else { 'Green' })
    Write-Host "  Skipped:   $($results.skipped.Count)" -ForegroundColor Yellow

    # Save results
    $resultsPath = Join-Path $dataDir 'generation-results.json'
    $results | ConvertTo-Json -Depth 10 | Set-Content -Path $resultsPath -Encoding UTF8

    return [PSCustomObject]$results
}

#endregion

# Execute if run directly
if ($MyInvocation.InvocationName -ne '.') {
    New-ZoomCmdletFromGap -GapReportPath $GapReportPath -MaxCmdlets $MaxCmdlets -Priority $Priority -DryRun:$DryRun -SkipProcessed:$SkipProcessed
}
