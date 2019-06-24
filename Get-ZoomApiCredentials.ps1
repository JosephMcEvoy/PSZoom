$Global:ZoomApiKey = 'xemREbnhSGyiH9dZ32obng'
$Global:ZoomApiSecret = 'OmVJSguTdBrh9YezNsJBqNkJ7Gpaax9rteQY'

<#

.SYNOPSIS
Gets a hashtable for a Zoom Api REST body that includes the api key and secret.

.EXAMPLE
$ZoomApiCredentials = Get-ZoomApiAuth

.OUTPUTS
Hashtable

.LINK
https://marketplace.zoom.us/docs/guides/authorization/jwt/jwt-with-zoom

.LINK
https://github.com/nickrod518/PowerShell-Scripts/tree/master/Zoom

#>

function Get-ZoomApiCredentials {
    [CmdletBinding()]
    Param()

    try {
        Write-Verbose -Message 'Retrieving Zoom API Credentials.'
        if (-not $Global:ZoomApiKey) {
            $Global:ZoomApiKey = if ($PSPrivateMetadata.JobId) {
                Get-AutomationVariable -Name ZoomApiKey
            } else {
                Read-Host 'Enter Zoom Api key (push ctrl + c to exit)'
            }
        }

        if (-not $Global:ZoomApiSecret) {
            $Global:ZoomApiSecret = if ($PSPrivateMetadata.JobId) {
                Get-AutomationVariable -Name ZoomApiSecret
            } else {
                Read-Host 'Enter Zoom Api secret (push ctrl + c to exit)'
            }
        }

        @{
            'ApiKey' = $Global:ZoomApiKey
            'ApiSecret' = $Global:ZoomApiSecret
        }
    } catch {
        Write-Error "Problem getting Zoom Api Authorization variables:`n$_"
    }
}