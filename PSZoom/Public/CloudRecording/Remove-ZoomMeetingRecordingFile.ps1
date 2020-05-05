<#

.SYNOPSIS
Delete a sprecific recording file from a meeting.

.DESCRIPTION
Delete a sprecific recording file from a meeting.

.PARAMETER MeetingId
The meeting ID or meeting UUID. If the meeting ID is provided instead of UUID,the response will be for the latest 
meeting instance. If a UUID starts with \"/\" or contains \"//\" (example: \"/ajXp112QmuoKj4854875==\"), you must 
**double encode** the UUID before making an API request. 

.PARAMETER Action
The recording delete action.
Trash - Move recording to trash. This is the default.
Delete - Delete recording permanently.

.PARAMETER RecordingId
The recording ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Send a meeting's recordings to the trash.
Remove-ZoomMeetingRecordings 123456789

.EXAMPLE
Send multiple meeting recordings to the trash.
Remove-ZoomMeetingRecordings 123456789,987654321

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/recordingdelete

#>

function Remove-ZoomMeetingRecordingFile {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Medium')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id', 'meetingids')]
        [string]$MeetingId,

        [Alias('recording_id', 'recordingids')]
        [string[]]$RecordingId,

        [ValidateSet('trash', 'delete')]
        [string]$Action = 'trash',

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach($RecId in $RecordingId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/recordings/$RecId"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('action', $Action)
            $Request.Query = $query.ToString()

            if ($PScmdlet.ShouldProcess($user, 'Remove')) {
                try {
                    $response = Invoke-RestMethod -Uri $request.Uri -Headers $Headers -Body $RequestBody -Method DELETE
                }
                catch {
                    Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
                }

                Write-Output $response
            }
        }
    }
}