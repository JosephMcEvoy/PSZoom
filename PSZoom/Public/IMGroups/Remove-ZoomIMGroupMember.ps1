<#

.SYNOPSIS
Delete a member from an IM directory group.

.DESCRIPTION
Delete a member from an IM directory group under an account.

.PARAMETER GroupId
The group ID.

.PARAMETER MemberId
The member ID.

.EXAMPLE
Remove-ZoomIMGroupMember -GroupId 'abc123' -MemberId 'user456'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imGroupMembersDelete

#>

function Remove-ZoomIMGroupMember {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'group_id')]
        [string]$GroupId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('member_id')]
        [string]$MemberId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/im/groups/$GroupId/members/$MemberId"

        if ($PSCmdlet.ShouldProcess($MemberId, 'Remove from IM group')) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
