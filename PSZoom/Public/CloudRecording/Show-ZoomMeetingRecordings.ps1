<#

.SYNOPSIS
Recover all the recordings from a meeting.

.DESCRIPTION
Recover all the recordings from a meeting.

.PARAMETER MeetingId
The meeting ID or meeting UUID. If the meeting ID is provided instead of UUID,the response will be for the latest 
meeting instance. If a UUID starts with \"/\" or contains \"//\" (example: \"/ajXp112QmuoKj4854875==\"), you must 
**double encode** the UUID before making an API request. 

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Recover a meeting's cloud recording.
Show-ZoomMeetingRecordings 123456789

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/recordingstatusupdate

#>

function Show-ZoomMeetingRecordings {
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
        #Double Encode MeetingId in case UUID needs it.
        $MeetingId = [uri]::EscapeDataString($MeetingId)
        $MeetingId = [uri]::EscapeDataString($MeetingId)
        
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/meetings/$MeetingId/recordings/status"

        
        $requestBody = @{}
        $requestBody.Add('action', 'recover')
        $requestBody = ConvertTo-Json $requestBody -Depth 10

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method PUT

        Write-Output $response
    }
}
