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
        $ClientSecret

    )

    $uri = "https://zoom.us/oauth/token?grant_type=account_credentials&account_id={0}" -f $AccountID

    #Encoding of the client data
    $IDSecret = $ClientID + ":" + $ClientSecret 
    $EncodedIDSecret = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($IDSecret))

    $headers = @{
        "Authorization" = "Basic $EncodedIDSecret"  
    }
            
    # Maybe add some error handling
    try {
        $response = Invoke-WebRequest -uri $uri -headers $headers -Method Post -UseBasicParsing
    } catch {
        $_
    }

    Write-Verbose 'Acquired token.'
    
    $token = ($response.content | ConvertFrom-Json).access_token

    $token = ConvertTo-SecureString -String $token -AsPlainText -Force

    
    Write-Output $token
}
