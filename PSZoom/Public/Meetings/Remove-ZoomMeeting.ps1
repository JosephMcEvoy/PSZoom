<#

.SYNOPSIS
Delete a meeting.
.DESCRIPTION
Delete a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OcurrenceId
The Occurrence ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Remove-ZoomMeeting 123456789

#>

function Remove-ZoomMeeting {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('occurrence_id')]
        [string]$OccurrenceId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('schedule_for_reminder')]
        [string]$ScheduleForReminder,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId"

        if ($PSBoundParameters.ContainsKey('OccurrenceId') -or $PSBoundParameters.ContainsKey('ScheduleForReminder')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            
            if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
                $query.Add('occurrence_id', $OccurrenceId)
            }  

            if ($PSBoundParameters.ContainsKey('ScheduleForReminder')){
                $query.Add('schedule_for_reminder', $ScheduleForReminder)
            }

            $Request.Query = $query.ToString()
        }

        try {
            $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method DELETE
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        if (-not $Passthru) {
            Write-Output $response
        } else {
            Write-Output $Passthru
        }
    }
}