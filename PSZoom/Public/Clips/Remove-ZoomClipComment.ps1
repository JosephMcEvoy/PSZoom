<#

.SYNOPSIS
Delete a clip comment.

.DESCRIPTION
Delete a specific comment from a clip. Use this API to permanently remove a comment from a Zoom Clip.
This action cannot be undone.

Scopes: clip:write, clip:write:admin

.PARAMETER ClipId
The clip ID.

.PARAMETER CommentId
The comment ID.

.OUTPUTS
Boolean - Returns $true if the comment was successfully deleted.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deleteClipComment

.EXAMPLE
Remove-ZoomClipComment -ClipId "abc123xyz" -CommentId "comment123"

Delete a specific comment from a clip.

#>

function Remove-ZoomClipComment {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('clip_id')]
        [string]$ClipId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('comment_id', 'id')]
        [string]$CommentId
    )

    process {
        if ($PSCmdlet.ShouldProcess("$ClipId - Comment: $CommentId", 'Remove clip comment')) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/$ClipId/comments/$CommentId"

            $null = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            Write-Output $true
        }
    }
}
