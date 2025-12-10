<#

.SYNOPSIS
Delete a phone recording.

.DESCRIPTION
Delete a specific phone recording from Zoom Phone.

.PARAMETER RecordingId
The recording ID.

.PARAMETER PassThru
Pass the RecordingId to the output.

.OUTPUTS
No output. Can use Passthru switch to pass RecordingId to output.

.EXAMPLE
Remove-ZoomPhoneRecording -RecordingId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteRecording

#>

function Remove-ZoomPhoneRecording {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id','Ids', 'recording_id')]
        [string[]]$RecordingId,

        [switch]$PassThru
    )

    process {
        foreach ($recId in $RecordingId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/recordings/$recId"

            $Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
"@

            if ($pscmdlet.ShouldProcess($Message, $recId, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $RecordingId
        }
    }
}
