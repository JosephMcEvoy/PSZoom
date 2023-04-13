<#

.SYNOPSIS
Retrieve a user’s settings.

.DESCRIPTION
Retrieve a user’s settings.

.PARAMETER UserId
The user ID or email address.

.PARAMETER LoginType
The user's login method:
0 — FacebookOAuth
1 — GoogleOAuth
24 — AppleOAuth
27 — MicrosoftOAuth
97 — MobileDevice
98 — RingCentralOAuth
99 — APIuser
100 — ZoomWorkemail
101 — SSO

The following login methods are only available in China:
11 — PhoneNumber
21 — WeChat
23 — Alipay

You can use the number or corresponding text (e.g. 'FacebookOauth' or '0').

.OUTPUTS
A hastable with the Zoom API response.

.EXAMPLE
Get-ZoomUserSettings jsmith@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/usersettings

#>

function Get-ZoomUserSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('login_type')]
        [string]$LoginType
     )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$UserId/settings"

        if ($PSBoundParameters.ContainsKey('LoginType')) {
            $LoginType = ConvertTo-LoginTypeCode -Code $LoginType
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('login_type', $LoginType)
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        Write-Output $response
    }
}