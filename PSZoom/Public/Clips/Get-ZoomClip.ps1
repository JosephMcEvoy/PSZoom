<#

.SYNOPSIS
Get details of a specific clip.

.DESCRIPTION
Get details of a specific clip. Use this API to get information about a specific Zoom Clip.

Scopes: clip:read, clip:read:admin

.PARAMETER ClipId
The clip ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getClip

.EXAMPLE
Get-ZoomClip -ClipId "abc123xyz"

Get details of a specific clip.

.EXAMPLE
"clip123", "clip456" | Get-ZoomClip

Get details for multiple clips via pipeline.

#>

function Get-ZoomClip {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('clip_id', 'id')]
        [string[]]$ClipId
    )

    process {
        foreach ($clip in $ClipId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/$clip"

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

            Write-Output $response
        }
    }
}
