<#

.SYNOPSIS
List clip comments.

.DESCRIPTION
Get a list of comments for a specific clip. Use this API to retrieve all comments that have been
added to a Zoom Clip.

Scopes: clip:read, clip:read:admin

.PARAMETER ClipId
The clip ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listClipComments

.EXAMPLE
Get-ZoomClipComments -ClipId "abc123xyz"

Get all comments for a specific clip.

.EXAMPLE
"clip123" | Get-ZoomClipComments

Get comments for a clip via pipeline.

#>

function Get-ZoomClipComments {
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
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/$clip/comments"

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

            Write-Output $response
        }
    }
}
