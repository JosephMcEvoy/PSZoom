<#

.SYNOPSIS
Delete a clip.

.DESCRIPTION
Delete a clip. Use this API to delete a specific Zoom Clip. This action is permanent and cannot be undone.

Scopes: clip:write, clip:write:admin

.PARAMETER ClipId
The clip ID.

.OUTPUTS
Boolean - Returns $true if the clip was successfully deleted.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deleteClip

.EXAMPLE
Remove-ZoomClip -ClipId "abc123xyz"

Delete a specific clip.

.EXAMPLE
"clip123", "clip456" | Remove-ZoomClip

Delete multiple clips via pipeline.

#>

function Remove-ZoomClip {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
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
            if ($PSCmdlet.ShouldProcess($clip, 'Remove clip')) {
                $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/$clip"

                $null = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

                Write-Output $true
            }
        }
    }
}
