<#

.SYNOPSIS
List specific user(s) on a Zoom account.

.DESCRIPTION
List specific user(s) on a Zoom account.

.PARAMETER UserId
The user ID or email address.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

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

        [ValidateSet('Facebook', 'Google', 'API', 'Zoom', 'SSO', 0, 1, 99, 100, 101)]
        [Alias('login_type')]
        [string]$LoginType,

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

            if ($PSBoundParameters.ContainsKey('LoginType')) {
                $LoginType = switch ($LoginType) {
                    'Facebook' { 0 }
                    'Google' { 1 }
                    'API' { 99 }
                    'Zoom' { 100 }
                    'SSO' { 101 }
                    Default { $LoginType }
                }
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
                $query.Add('login_type', $LoginType)
                $Request.Query = $query.ToString()
            }

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret

            Write-Output $response
        }
    }
}