<#

.SYNOPSIS
Update a user's email.
.DESCRIPTION
Update a user's email.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Email
User's email. The length should be less than 128 characters.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Update-ZoomUserEmail jsmith@lawfirm.com
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Update-ZoomUserEmail {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('EmailAddress', 'Id', 'UserId')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(0,128)]
        [string]$Email,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/email"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $Query.Add('email', $Email)
        $Request.Query = $Query.ToString()

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method PUT
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}