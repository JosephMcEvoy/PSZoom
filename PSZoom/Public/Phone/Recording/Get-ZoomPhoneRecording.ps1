<#

.SYNOPSIS
Get recording details.

.DESCRIPTION
Get detailed information for a specific phone recording.

.PARAMETER RecordingId
The recording ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Get-ZoomPhoneRecording -RecordingId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getRecording

#>

function Get-ZoomPhoneRecording {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'recording_id')]
        [string[]]$RecordingId
    )

    process {
        foreach ($recId in $RecordingId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/recordings/$recId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
