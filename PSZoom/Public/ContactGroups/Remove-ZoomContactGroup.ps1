<#

.SYNOPSIS
Delete a contact group.

.DESCRIPTION
Deletes a contact group.

.PARAMETER GroupId
The contact group ID to delete.

.EXAMPLE
Remove-ZoomContactGroup -GroupId "abc123"

.EXAMPLE
Remove-ZoomContactGroup -GroupId "abc123" -WhatIf

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroupDelete

#>

function Remove-ZoomContactGroup {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('group_id', 'id')]
        [string]$GroupId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups/$GroupId"

        if ($PSCmdlet.ShouldProcess($GroupId, 'Delete contact group')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Delete

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
