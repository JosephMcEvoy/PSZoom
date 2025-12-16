<#

.SYNOPSIS
Remove members from a contact group.

.DESCRIPTION
Removes one or more members from a contact group. Maximum 20 members per request.

.PARAMETER GroupId
The contact group ID.

.PARAMETER MemberIds
An array of member IDs to remove. Maximum 20 IDs per request.

.EXAMPLE
Remove-ZoomContactGroupMember -GroupId "abc123" -MemberIds "user456"

.EXAMPLE
Remove-ZoomContactGroupMember -GroupId "abc123" -MemberIds @("user456", "user789")

.EXAMPLE
Remove-ZoomContactGroupMember -GroupId "abc123" -MemberIds @("user456") -WhatIf

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroupMemberRemove

#>

function Remove-ZoomContactGroupMember {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Medium')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('group_id', 'id')]
        [string]$GroupId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('member_ids')]
        [string[]]$MemberIds
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups/$GroupId/members"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $memberIdsString = $MemberIds -join ','
        $query.Add('member_ids', $memberIdsString)

        $Request.Query = $query.ToString()

        if ($PSCmdlet.ShouldProcess("$($MemberIds.Count) member(s) from group $GroupId", 'Remove')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Delete

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
