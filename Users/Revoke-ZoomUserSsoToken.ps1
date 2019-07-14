<#

.SYNOPSIS
Revoke a user’s SSO token.
.DESCRIPTION
Revoke a user’s SSO token.
.PARAMETER UserId
The user ID or email address.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Revoke-UserSsoToken jsmith@lawfirm.com
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Revoke-ZoomUserSsoToken {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id')]
        [string]$UserId,

        [ValidateSet('token', 'zpk', 'zap')]
        [string]$Type,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Revoke Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Revoke-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/token"

        if ($Type) {
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $Query.Add('login_type', $Type)
            $Request.Query = $Query.ToString()
        }

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method DELETE
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}