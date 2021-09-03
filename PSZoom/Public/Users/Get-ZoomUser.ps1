<#

.SYNOPSIS
List specific user(s) on a Zoom account.

.DESCRIPTION
List specific user(s) on a Zoom account.

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

.PARAMETER EncryptedEmail
Whether the email address passed for the $UserId value is an encrypted email address. 
Add the -EncryptedEmail switch to specify this is $True.

.PARAMETER ApiKey
The API Key.

.PARAMETER ApiSecret
The API Secret.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a user's info.
Get-ZoomUser jsmith@lawfirm.com

.EXAMPLE
Get the host of a Zoom meeting.
Get-ZoomMeeting 123456789 | Select-Object host_id | Get-ZoomUser

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/user


#>

function Get-ZoomUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('email', 'emailaddress', 'id', 'user_id', 'ids', 'userids', 'emails', 'emailaddresses', 'host_id')]
        [string[]]$UserId,

        [Alias('login_type')]
        [string]$LoginType,

        [Alias('encrypted_email')]
        [switch]$EncryptedEmail,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($id in $UserId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$id"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

            if ($PSBoundParameters.ContainsKey('EncryptedEmail')) {
                $query.Add('EncryptedEmail', $True)
            }

            if ($PSBoundParameters.ContainsKey('LoginType')) {
                $LoginType = ConvertTo-LoginTypeCode -Code $LoginType
                $query.Add('login_type', $LoginType)
            }
            
            $Request.Query = $query.ToString()
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret

            Write-Output $response
        }
    }
}