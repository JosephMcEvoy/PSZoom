<#

.SYNOPSIS
Delete members from groups under your account.
.DESCRIPTION
Delete members from groups under your account.
The default Zoom Api being used here supports deleting one member from one group.
This function expands off that, allowing multiple members to be deleted from multiple groups.
Prerequisite: Pro, Business, or Education account.
.PARAMETER GroupId
This is the ID of the group. Not to be confused with MemberId. This also has the alias 'id'. 
This is for better pipeline support with other functions. Other aliases include 'group_id' and 'group'.
.PARAMETER MemberIds
This is the ID of the member. Not to be confused with the GroupId. MemberId is an alias.

.OUTPUTS
"Group member deleted."
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupmembersdelete
.EXAMPLE
Remove a user from all groups that include the word Training in the name.
(Get-ZoomGroups).groups | where-object {$_ -like '*Training*'} | Remove-ZoomGroupMembers -memberids ((get-zoomspecificuser 'lskywalker@swars.com').id)

#>

function Remove-ZoomGroupMembers {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Medium')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string[]]$GroupIds,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [Alias('memberid')]
        [string[]]$MemberIds
    )

    process {
        foreach ($GroupId in $GroupIDs) {
            #Need to add API rate limiting
            foreach ($MemberId in $MemberIds) {
                $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$GroupId/members/$MemberId"
                
                if ($PScmdlet.ShouldProcess("Removing $MemberId from $GroupId", $MemberId, 'Remove Group Member')) {
                    Write-Verbose "Removing $MemberId from $GroupId."
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

                    Write-Output $response
                }
            }
        }
    }
}