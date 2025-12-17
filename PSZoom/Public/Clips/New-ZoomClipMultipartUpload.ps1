<#

.SYNOPSIS
Create a multipart clip upload.

.DESCRIPTION
Create a multipart clip upload session. Use this API to initiate a multipart upload for large
Zoom Clip files. Multipart uploads allow you to upload large files in chunks, making the process
more reliable and resumable.

Scopes: clip:write, clip:write:admin

.OUTPUTS
System.Object - Returns an object containing multipart upload session details.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/createClipMultipartUpload

.EXAMPLE
New-ZoomClipMultipartUpload

Create a new multipart upload session.

#>

function New-ZoomClipMultipartUpload {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param ()

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/files/multipart"

        if ($PSCmdlet.ShouldProcess("Multipart Upload", "Create Clip Multipart Upload Session")) {
        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method POST

        Write-Output $response
        }
    }
}
