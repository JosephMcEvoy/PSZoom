<#

.SYNOPSIS
Send a multipart upload event.

.DESCRIPTION
Send a multipart upload event. Use this API to send events during a multipart clip upload session,
such as signaling the completion of a chunk upload or finalizing the entire upload process.

Scopes: clip:write, clip:write:admin

.OUTPUTS
System.Object - Returns the response from the multipart upload event.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/sendClipMultipartUploadEvent

.EXAMPLE
Send-ZoomClipMultipartEvent

Send a multipart upload event.

#>

function Send-ZoomClipMultipartEvent {
    [CmdletBinding()]
    param ()

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/files/multipart/upload_events"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method POST

        Write-Output $response
    }
}
