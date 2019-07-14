<#

.SYNOPSIS
Update a user's password.
.DESCRIPTION
Update a user's password.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Password
User password. Minimum of 8 characters. Maximum of 31 characters.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.EXAMPLE`
Update-ZoomUserPassword -UserId helpdesk@lawfirm.com -Password 'Zoompassword'
.OUTPUTS
The Zoom API response as a hashtable.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"
. "$PSScriptRoot\Get-ZoomSpecificUser.ps1"

function Update-ZoomUserpassword {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'EmailAddress', 'Id')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateLength(8,31)]
        [string]$Password,

        [string]$ApiKey,
        
        [string]$ApiSecret,

        [switch]$PassThru
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/password"
        $RequestBody = @{
            'password' = $Password
        }

        if ($pscmdlet.ShouldProcess) {
            try {
                Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method PUT
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            } finally {
                if ($PassThru) {
                    if ($_.Exception.Code -ne 404) {
                        Get-ZoomSpecificUser -UserId $UserId
                    }
                }
            }
        }
    }
}