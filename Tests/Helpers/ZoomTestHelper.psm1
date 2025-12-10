<#
.SYNOPSIS
    Helper module for PSZoom integration tests.

.DESCRIPTION
    Provides functions to check for and use Zoom API credentials in integration tests.
    Credentials are read from environment variables (set by CI) or can be passed directly.

    Environment Variables:
    - ZOOM_ACCOUNT_ID: Zoom account ID for Server-to-Server OAuth
    - ZOOM_CLIENT_ID: OAuth client ID
    - ZOOM_CLIENT_SECRET: OAuth client secret

.NOTES
    This module should be imported in integration tests that require live API access.
    Unit tests should NOT use this module - they should mock API calls instead.
#>

function Test-ZoomCredentialsAvailable {
    <#
    .SYNOPSIS
        Tests if Zoom API credentials are available in environment variables.

    .DESCRIPTION
        Checks for ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, and ZOOM_CLIENT_SECRET environment variables.
        Returns $true if all three are present and non-empty.

    .EXAMPLE
        if (Test-ZoomCredentialsAvailable) {
            # Run integration tests
        } else {
            Set-ItResult -Skipped -Because 'Zoom API credentials not configured'
        }
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $accountId = $env:ZOOM_ACCOUNT_ID
    $clientId = $env:ZOOM_CLIENT_ID
    $clientSecret = $env:ZOOM_CLIENT_SECRET

    $available = -not [string]::IsNullOrWhiteSpace($accountId) -and
                 -not [string]::IsNullOrWhiteSpace($clientId) -and
                 -not [string]::IsNullOrWhiteSpace($clientSecret)

    if (-not $available) {
        Write-Verbose "Zoom credentials not available. Set ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, and ZOOM_CLIENT_SECRET environment variables."
    }

    return $available
}

function Connect-ZoomTestAccount {
    <#
    .SYNOPSIS
        Connects to Zoom using credentials from environment variables.

    .DESCRIPTION
        Reads Zoom API credentials from environment variables and calls Connect-PSZoom.
        This should only be used in integration tests, not unit tests.

    .EXAMPLE
        BeforeAll {
            Import-Module $PSScriptRoot/../Helpers/ZoomTestHelper.psm1
            if (Test-ZoomCredentialsAvailable) {
                Connect-ZoomTestAccount
            }
        }

    .NOTES
        Throws an error if credentials are not available.
    #>
    [CmdletBinding()]
    param()

    if (-not (Test-ZoomCredentialsAvailable)) {
        throw "Zoom API credentials not available. Cannot connect for integration testing."
    }

    $accountId = $env:ZOOM_ACCOUNT_ID
    $clientId = $env:ZOOM_CLIENT_ID
    $clientSecret = ConvertTo-SecureString $env:ZOOM_CLIENT_SECRET -AsPlainText -Force

    Write-Verbose "Connecting to Zoom with account ID: $accountId"

    Connect-PSZoom -AccountId $accountId -ClientId $clientId -ClientSecret $clientSecret
}

function Get-ZoomTestSkipReason {
    <#
    .SYNOPSIS
        Returns a skip reason for integration tests when credentials are unavailable.

    .DESCRIPTION
        Use this with Set-ItResult -Skipped to skip tests that require live API access.

    .EXAMPLE
        It 'Should return real users from API' -Tag 'Integration' {
            if (-not (Test-ZoomCredentialsAvailable)) {
                Set-ItResult -Skipped -Because (Get-ZoomTestSkipReason)
                return
            }
            # Test code here
        }
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return "Zoom API credentials not configured (ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, ZOOM_CLIENT_SECRET)"
}

Export-ModuleMember -Function @(
    'Test-ZoomCredentialsAvailable'
    'Connect-ZoomTestAccount'
    'Get-ZoomTestSkipReason'
)
