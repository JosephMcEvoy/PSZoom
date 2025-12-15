<#

.SYNOPSIS
Delete an IM directory group under an account.

.DESCRIPTION
Delete an IM directory group under an account.

.PARAMETER GroupId
The group ID.

.EXAMPLE
Remove-ZoomIMGroup -GroupId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imGroupDelete

#>

function Remove-ZoomIMGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'group_id')]
        [string]$GroupId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/im/groups/$GroupId"

        if ($PSCmdlet.ShouldProcess($GroupId, 'Delete IM group')) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
