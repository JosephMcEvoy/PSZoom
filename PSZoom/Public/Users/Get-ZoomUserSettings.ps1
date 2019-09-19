<#

.SYNOPSIS
Retrieve a user’s settings.
.DESCRIPTION
Retrieve a user’s settings.
.PARAMETER UserId
The user ID or email address.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
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
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/settings"

        if ($PSBoundParameters.ContainsKey('LoginType')) {
            $LoginType = switch ($LoginType) {
                'Facebook' { 0 }
                'Google' { 1 }
                'API' { 99 }
                'Zoom' { 100 }
                'SSO' { 101 }
                Default { $LoginType }
            }
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $Query.Add('login_type', $LoginType)
            $Request.Query = $Query.ToString()
        }

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}