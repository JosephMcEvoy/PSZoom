<#

.SYNOPSIS
Retrieve the details of a meeting.
.DESCRIPTION
Retrieve the details of a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OcurrenceId
The occurence ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomEndedMeetingInstances 123456789


#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Get-ZoomEndedMeetingInstances {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            Position = 0
        )]
        [string]$MeetingId,

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

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/past_meetings/$MeetingId/instances"
   
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}