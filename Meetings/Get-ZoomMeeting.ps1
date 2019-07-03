<#

.SYNOPSIS
Retrieve the details of a meeting.
.DESCRIPTION
Retrieve the details of a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomMeeting 123456789
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Get-ZoomMeeting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline=$True, Position=0)]
        [string]$MeetingId,

        [Parameter(Position=1)]
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
        $Uri = "https://api.zoom.us/v2/meetings/$MeetingId"
        $RequestBody = @{ }

        if ($OcurrenceId) {
            $RequestBody.Add('occurrence_id', $OcurrenceId)
        }
        
        try {
            $Response = Invoke-RestMethod -Uri $Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}
