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

.PARAMETER Token
You can pass an existing valid token to Connect-PSZoom instead of the ClientID, ClientSecret, and AccountID. 
String types will automatically be converted to SecureString. SecureStrings can also be passed.

.PARAMETER APIConnection
Zoom environment for specified AccountID
- Zoom.us
- Zoomgov.com

.EXAMPLE
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret'

.EXAMPLE
Connect-PSZoom -AccountID 'your_account_id' -ClientID 'your_client_id' -ClientSecret 'your_client_secret' -$APIConnection 'Zoom.us'

.EXAMPLE
Connect-PSZoom -Token 'lkjahsdklasjhdkasljhdas789d6891276d12khjgaskjd8as7968as796d897as6d897as6dashjkgdasjkh'

.EXAMPLE
$token = 'lkjahsdklasjhdkasljhdas789d6891276d12khjgaskjd8as7968as796d897as6d897as6dashjkgdasjkh' | ConvertTo-SecureString -AsPlainText -Force
Connect-PSZoom -Token $token

#>

function Connect-PSZoom {
    [CmdletBinding(
        DefaultParameterSetName = 'APIKey'
    )]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0,
            ParameterSetName = "APIKey"
        )]
        [string]$AccountID,

        [Alias('APIKey')]
        [Parameter(
            Mandatory = $True, 
            Position = 1,
            ParameterSetName = "APIKey"
        )]
        [string]$ClientID,

        [Alias('APISecret')]
        [Parameter(
            Mandatory = $True, 
            Position = 2,
            ParameterSetName = "APIKey"
        )]
        [string]$ClientSecret,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = "Token"
        )]
        $Token,

        [Alias('SiteConnection')]
        [Parameter(
            Mandatory = $False,
            ParameterSetName = "APIKey"
        )]
        [ValidateSet("Zoom.Us","Zoomgov.com")]
        [string]$APIConnection = "Zoom.us"
    )

    try {
        $Script:ZoomURI = $APIConnection

        if ($PSCmdlet.ParameterSetName -eq 'Token') {
            if ($Token.getType().name -eq 'String') {
                $Token = ConvertTo-SecureString -String $Token -AsPlainText -Force
            }
        } else {
            $Token = New-OAuthToken -AccountID $AccountID -ClientID $ClientID -ClientSecret $ClientSecret
        }
        
        $Script:PSZoomToken = $Token
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
