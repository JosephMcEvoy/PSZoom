<#

.SYNOPSIS
Create a new contact group.

.DESCRIPTION
Creates a new contact group for organizing contacts.

.PARAMETER GroupName
The name of the contact group.

.PARAMETER GroupPrivacy
The privacy level of the group:
1 - Only group members can see the group
2 - Anyone in the organization can see the group
3 - Anyone in the organization can see and join the group

.PARAMETER Description
A description of the contact group.

.PARAMETER GroupMembers
An array of group members to add. Each member should be a hashtable with 'type' (1=user, 2=user group) and 'id' properties.
Maximum 50 users and 3 groups per request.

.EXAMPLE
New-ZoomContactGroup -GroupName "Engineering Team" -GroupPrivacy 2

.EXAMPLE
$members = @(
    @{ type = 1; id = "user123" },
    @{ type = 1; id = "user456" }
)
New-ZoomContactGroup -GroupName "Project Team" -GroupPrivacy 1 -Description "Project Alpha team" -GroupMembers $members

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroupCreate

#>

function New-ZoomContactGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('group_name', 'name')]
        [string]$GroupName,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('group_privacy', 'privacy')]
        [ValidateRange(1, 3)]
        [int]$GroupPrivacy,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('group_members', 'members')]
        [array]$GroupMembers
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups"

        $body = @{
            group_name    = $GroupName
            group_privacy = $GroupPrivacy
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $body.Add('description', $Description)
        }

        if ($PSBoundParameters.ContainsKey('GroupMembers')) {
            $body.Add('group_members', $GroupMembers)
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Post

        Write-Output $response
    }
}
