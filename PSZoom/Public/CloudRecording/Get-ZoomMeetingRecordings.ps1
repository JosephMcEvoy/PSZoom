<#

.SYNOPSIS
Get all the recordings from a meeting.

.DESCRIPTION
Get all the recordings from a meeting.

.PARAMETER MeetingId
The meeting ID or meeting UUID. If the meeting ID is provided instead of UUID,the response will be for the latest 
meeting instance. If a UUID starts with \"/\" or contains \"//\" (example: \"/ajXp112QmuoKj4854875==\"), you must 
**double encode** the UUID before making an API request. 

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a meeting's cloud recording info.
Get-ZoomMeetingRecordings 123456789

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/recordingget

#>

function Get-ZoomMeetingRecordings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId
     )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/recordings"

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET

        Write-Output $response
    }
}