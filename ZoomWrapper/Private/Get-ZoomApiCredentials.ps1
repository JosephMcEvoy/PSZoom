<#

.SYNOPSIS
Gets a hashtable for a Zoom Api REST body that includes the api key and secret.
.EXAMPLE
$ZoomApiCredentials = Get-ZoomApiCredentials
.OUTPUTS
Hashtable
.LINK
https://marketplace.zoom.us/docs/guides/authorization/jwt/jwt-with-zoom
.LINK
https://github.com/nickrod518/PowerShell-Scripts/tree/master/Zoom

#>

function Get-ZoomApiCredentials {
    [CmdletBinding()]
    Param (
        [string]$ZoomApiKey, 
        [string]$ZoomApiSecret
    )
    
    try {
        Write-Verbose -Message 'Retrieving Zoom API Credentials.'

        if (-not $Global:ZoomApiKey) {
            if (-not [string]::IsNullOrWhiteSpace($ZoomApiKey)) {
                $Global:ZoomApiKey = $ZoomApiKey
            } else {
                $Global:ZoomApiKey = if ($PSPrivateMetadata.JobId) {
                        Get-AutomationVariable -Name ZoomApiKey
                    }
                    else {
                        Read-Host 'Enter Zoom Api key (push ctrl + c to exit)'
                    }
                }
        }

        if (-not $Global:ZoomApiSecret) {
            if (-not [string]::IsNullOrWhiteSpace($ZoomApiSecret)) {
                $Global:ZoomApiSecret = $ZoomApiSecret
            } else {
                $Global:ZoomApiSecret = if ($PSPrivateMetadata.JobId) {
                        Get-AutomationVariable -Name ZoomApiSecret
                    }
                    else {
                        Read-Host 'Enter Zoom Api Secret (push ctrl + c to exit)'
                    }
                }
        }

        @{
            'ApiKey'    = $Global:ZoomApiKey
            'ApiSecret' = $Global:ZoomApiSecret
        }

        Write-Verbose 'Retrieved API Credentials.'
    }
    catch {
        Write-Error "Problem getting Zoom Api Authorization variables:`n$_"
    }
}
