<#
.SYNOPSIS
Use this cmdlet to retrieve a token from Zoom.

.DESCRIPTION
Assigns a token to the variable $Script:PSZoomToken which is used by all cmdlets when making requests to Zoom.

.PARAMETER ClientID
Client ID of the Zoom App

.PARAMETER ClientSecret
Client Secret of the Zoom App

.PARAMETER AccountID
Account ID of the Zoom App

.PARAMETER APIConnection
Zoom environment for specified AccountID
- Zoom.us
- Zoomgov.com

.EXAMPLE
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret'

.EXAMPLE
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret' -$APIConnection 'Zoom.us'

#>

function Connect-PSZoom {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0
        )]
        [string]$AccountID,

        [Alias('APIKey')]
        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [string]$ClientID,

        [Alias('APISecret')]
        [Parameter(
            Mandatory = $True, 
            Position = 2
        )]
        [string]$ClientSecret,

        [Alias('SiteConnection')]
        [Parameter(
            Mandatory = $False
        )]
        [ValidateSet("Zoom.Us","Zoomgov.com")]
        [string]$APIConnection = "Zoom.us"
    )

    try {
        $Script:ZoomURI = $APIConnection
        $token = New-OAuthToken -AccountID $AccountID -ClientID $ClientID -ClientSecret $ClientSecret
        $Script:PSZoomToken = $token
    } catch {
        if ($_.exception.Response) {
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                $errorStreamReader = [System.IO.StreamReader]::new($_.exception.Response.GetResponseStream())
                $errorDetails = ConvertFrom-Json ($errorStreamReader.ReadToEnd())
            }
            else {
                $errorDetails = ConvertFrom-Json $_.errorDetails -AsHashtable
            }
        }

        Write-Error "Unable to retrieve token for account ID $AccountID. $($errorDetails.reason)"
    }
}
