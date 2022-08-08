<#

.SYNOPSIS
End a meeting by updating its status.

.DESCRIPTION
End a meeting by updating its status.

.PARAMETER MeetingId
The meeting ID.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/recordingsettingupdate

.EXAMPLE
Get-ZoomMeetingRecordingsSettings -MeetingId 1234567890

#>

function Get-ZoomMeetingRecordingsSettings {
    [CmdletBinding(ConfirmImpact='Medium')]
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

        $request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/recordings/settings"

        if ($pscmdlet.ShouldProcess) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method GET

            Write-Output $response
        }
    }
}
