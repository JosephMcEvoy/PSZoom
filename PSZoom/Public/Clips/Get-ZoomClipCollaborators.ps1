<#

.SYNOPSIS
List clip collaborators.

.DESCRIPTION
Get a list of collaborators for a specific clip. Use this API to list all users who have been granted
access to collaborate on a Zoom Clip.

Scopes: clip:read, clip:read:admin

.PARAMETER ClipId
The clip ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listClipCollaborators

.EXAMPLE
Get-ZoomClipCollaborators -ClipId "abc123xyz"

Get all collaborators for a specific clip.

.EXAMPLE
"clip123" | Get-ZoomClipCollaborators

Get collaborators for a clip via pipeline.

#>

function Get-ZoomClipCollaborators {
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
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/$clip/collaborators"

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

            Write-Output $response
        }
    }
}
