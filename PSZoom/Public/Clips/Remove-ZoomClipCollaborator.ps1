<#

.SYNOPSIS
Remove clip collaborators.

.DESCRIPTION
Remove collaborators from a clip. Use this API to revoke access for one or more collaborators on a
Zoom Clip. This will remove their ability to edit or view the clip.

Scopes: clip:write, clip:write:admin

.PARAMETER ClipId
The clip ID.

.PARAMETER CollaboratorIds
An array of collaborator IDs to remove from the clip.

.OUTPUTS
Boolean - Returns $true if the collaborators were successfully removed.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deleteClipCollaborators

.EXAMPLE
Remove-ZoomClipCollaborator -ClipId "abc123xyz" -CollaboratorIds @("user1@example.com", "user2@example.com")

Remove multiple collaborators from a clip.

.EXAMPLE
Remove-ZoomClipCollaborator -ClipId "clip123" -CollaboratorIds "user@example.com"

Remove a single collaborator from a clip.

#>

function Remove-ZoomClipCollaborator {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('clip_id', 'id')]
        [string]$ClipId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('collaborator_ids')]
        [string[]]$CollaboratorIds
    )

    process {
        if ($PSCmdlet.ShouldProcess($ClipId, "Remove collaborators: $($CollaboratorIds -join ', ')")) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/$ClipId/collaborators"

            $requestBody = @{
                collaborator_ids = $CollaboratorIds
            }

            $requestBody = ConvertTo-Json $requestBody -Depth 10

            $null = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method DELETE

            Write-Output $true
        }
    }
}
