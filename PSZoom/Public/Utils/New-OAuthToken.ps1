function New-OAuthToken {

    <#
    .SYNOPSIS
    Retrieves the Zoom OAuth API token

    .PARAMETER ClientID
    Client ID of the Zoom App

    .PARAMETER ClientSecret
    Client Secret of the Zoom App

    .PARAMETER AccountID
    Account ID of the Zoom App

    .OUTPUTS
    Zoom API Response

    .NOTES
    Version:        1.0
    Author:         noaboa97
    Creation Date:  20.07.2022
    Purpose/Change: Initial function development
  
    .EXAMPLE
    $clientid = "YourClientID"
    $clientsecret = "YourClientSecret"
    $AccountID = "YourAccountID"

    New-OAuth -ClientID $clientid -ClientSecret $clientsecret -AccountID $AccountID

    .EXAMPLE
    $token = New-OAuth -ClientID $clientid -ClientSecret $clientsecret -AccountID $AccountID

    .LINK
    https://marketplace.zoom.us/docs/guides/build/server-to-server-oauth-app/

    .LINK
    https://marketplace.zoom.us/docs/guides/auth/oauth
    
    #>

    [CmdletBinding()]
    param (
        [Parameter(valuefrompipeline = $true, mandatory = $true, HelpMessage = "Enter Zoom App Account ID", Position = 0)]
        [String]
        $AccountID,

        [Parameter(valuefrompipeline = $true, mandatory = $true, HelpMessage = "Enter Zoom App Client ID:", Position = 1)]
        [String]
        $ClientID,

        [Parameter(valuefrompipeline = $true, mandatory = $true, HelpMessage = "Enter Zoom App Client Secret:", Position = 2)]
        [String]
        $ClientSecret,

        [Parameter(valuefrompipeline = $true, mandatory = $true, Position = 3)]
        [ValidateSet('Zoom.Us','Zoomgov.com')]
        [string]$APIConnection = 'Zoom.us'

    )

    # Handles this cmdlet being called on its own (without being called from Connect-PSZoom)
    if ($APIConnection){
        $Script:ZoomURI = $APIConnection
    }

    $uri = "https://{1}/oauth/token?grant_type=account_credentials&account_id={0}" -f $AccountID, $ZoomURI

    #Encoding of the client data
    $IDSecret = $ClientID + ":" + $ClientSecret 
    $EncodedIDSecret = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($IDSecret))

    $headers = @{
        "Authorization" = "Basic $EncodedIDSecret"  
    }
            
    try {
        # Use Invoke-RestMethod instead of Invoke-WebRequest to avoid IE dependency issues
        # and simplify JSON parsing (Invoke-RestMethod automatically parses JSON responses)
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post
    } catch {
        Write-Error "Failed to acquire OAuth token: $_"
        throw
    }

    if (-not $response.access_token) {
        Write-Error "OAuth response did not contain an access_token"
        throw "Invalid OAuth response"
    }

    Write-Verbose 'Acquired token.'

    $token = ConvertTo-SecureString -String $response.access_token -AsPlainText -Force

    Write-Output $token
}
