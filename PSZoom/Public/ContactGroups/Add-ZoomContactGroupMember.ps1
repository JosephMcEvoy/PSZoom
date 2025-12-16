<#

.SYNOPSIS
Add members to a contact group.

.DESCRIPTION
Adds one or more members to a contact group. Maximum 50 users and 3 groups per request.

.PARAMETER GroupId
The contact group ID.

.PARAMETER GroupMembers
An array of members to add. Each member should be a hashtable with:
- type (integer): 1 for user, 2 for user group
- id (string): The member ID

.EXAMPLE
$members = @(
    @{ type = 1; id = "user123" }
)
Add-ZoomContactGroupMember -GroupId "abc123" -GroupMembers $members

.EXAMPLE
$members = @(
    @{ type = 1; id = "user123" },
    @{ type = 1; id = "user456" },
    @{ type = 2; id = "group789" }
)
Add-ZoomContactGroupMember -GroupId "abc123" -GroupMembers $members

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroupMemberAdd

#>

function Add-ZoomContactGroupMember {
    [CmdletBinding()]
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
        [Alias('group_members', 'members')]
        [array]$GroupMembers
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups/$GroupId/members"

        $body = @{
            group_members = $GroupMembers
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Post

        Write-Output $response
    }
}
