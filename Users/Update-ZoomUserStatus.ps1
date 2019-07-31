<#

.SYNOPSIS
Update a user's status.
.DESCRIPTION
Update a user's status.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Action
The action types:
Activate - Set user status to active.
Deactivate - Set user status to inactive.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.OUTPUTS
No output. Can use Passthru switch to pass the UserId as an output.
.EXAMPLE`
Update-ZoomUserStatus -UserId helpdesk@lawfirm.com
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userstatus

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"
. "$PSScriptRoot\Get-ZoomSpecificUser.ps1"

function Update-ZoomUserStatus {    
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
        [ValidateSet('activate', 'deactivate')]
        [string]$Action,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,
        
        [ValidateNotNullOrEmpty()]
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/status"
        $RequestBody = @{
            'action' = $Action
        }

        if ($pscmdlet.ShouldProcess) {
            try {
                Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method PUT
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            } finally {
                if ($PassThru) {
                    Write-Output $UserId
                }
            }
        }
    }
}