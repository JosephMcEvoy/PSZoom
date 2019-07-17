<#

.SYNOPSIS
Retrieve the details of a past meeting.
.DESCRIPTION
Retrieve the details of a past meeting.
.PARAMETER MeetingUuid
The meeting UUID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomPastMeetingDetails 123456789


#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Get-ZoomPastMeetingDetails {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            Position = 0
        )]
        [Alias('uuid')]
        [string]$Meetinguuid,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [string]$OcurrenceId,

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
        $Uri = "https://api.zoom.us/v2/past_meetings/$MeetingUuid"
        $RequestBody = @{ }
        
        try {
            $Response = Invoke-RestMethod -Uri $Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}

Get-ZoomPastMeetingDetails '445409231'
