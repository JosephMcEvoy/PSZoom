<#

.SYNOPSIS
Delete a group under your account.
.DESCRIPTION
Delete a group under your account.
Prerequisite: Pro, Business, or Education account.
.PARAMETER GroupId
The group ID.

.OUTPUTS
No output.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupdelete
.EXAMPLE
Remove-ZoomGroup
.EXAMPLE
Remove a user from all groups that include the word Training in the name.
(Get-ZoomGroups).groups | where-object {$_ -like '*Training*'} | Remove-ZoomGroup

#>

function Remove-ZoomGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Alias('Remove-ZoomGroups')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id', 'groupids')]
        [string[]]$GroupId
    )

    process {
        foreach ($Id in $GroupID) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$Id"
            if ($PSCmdlet.ShouldProcess($Id, "Remove")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE
                Write-Verbose "Group $Id deleted."
                Write-Output $response
            }
        }
    }
}