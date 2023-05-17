<#

.SYNOPSIS
Add members to a under your account.

.DESCRIPTION
Add members to a under your account.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.PARAMETER Email
Emails to be added to the group.

.PARAMETER Id
IDs to be added to the group.

.OUTPUTS
The Zoom response (an object). Example:
ids                    added_at
---                    --------
tKODqjp0S456QzjjcNQqVg 2019-08-28T22:39:51Z

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupmemberscreate

.EXAMPLE
Add a single user to a single group.
$GroupId = ((Get-ZoomGroups) | where-object {$_ -eq 'Light Side'}).id
Add-ZoomGroupMembers -group $GroupID -Email okenobi@lightside.com, lskywalker@lightside.com

.EXAMPLE
Add users to a single group.
Get-ZoomGroups | where-object {$_ -eq 'Dark Side'} | Add-ZoomGroupMembers -email 'dvader@sith.org','dsidious@sith.org'

.EXAMPLE
Add a single user to all groups matching 'Side'.
Get-ZoomGroups | where-object {$_ -like '*Side*'} | Add-ZoomGroupMembers -email 'askywalker@theforce.com'

.EXAMPLE
Find all users without a group then select users based off of Office location from Active Directory
then add them to a group.
(((get-zoomusers -all) | where-object group_ids -eq $Null).email).replace('@domain.com','') | ```
get-aduser -property office,EmailAddress | where-object office -eq 'New Mexico' | select emailaddress | ```
get-zoomuser | select id | Add-ZoomGroupMembers -groupid xxxxxxSQQKvOyy234gd

#>

function Add-ZoomGroupMember  {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Low')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'groups', 'id', 'groupids')]
        [string[]]$GroupId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [Alias('email', 'emails', 'emailaddress', 'emailaddresses', 'memberemails')]
        [string[]]$MemberEmail,

        [Parameter(
            Position = 2
        )]
        [Alias('memberids')]
        [string[]]$MemberId,

        [switch]$Passthru
    )

    process {
        $requestBody = @{}

        $members = New-Object System.Collections.Generic.List[System.Object]

        if (-not $MemberEmail -and -not $MemberId) {
            throw 'At least one email or ID is required.'
        }

        if ($PSBoundParameters.ContainsKey('MemberEmail')) {
            $MemberEmail | ForEach-Object {
                $members.Add(@{email = $_})
            }
        }

        if ($PSBoundParameters.ContainsKey('MemberId')) {
            $MemberId | ForEach-Object {
                $members.Add(@{id = $_})
            }
        }

        if ($members.Count -gt 30) {
            throw 'Maximum amount of members that can be added at a time is 30.' #This limit is set by Zoom.
        }

        $requestBody.Add('members', $members)
        
        $requestBody = $requestBody | ConvertTo-Json

        foreach ($Id in $GroupId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$Id/members"
            if ($PScmdlet.ShouldProcess($members, 'Add')) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method POST

                if (-not $passthru) {
                    Write-Output $response
                }
            }
        }

        if ($passthru) {
            Write-Output $GroupId
        }
    }
}