<#

.SYNOPSIS
Update a contact group.

.DESCRIPTION
Updates an existing contact group's name, privacy level, or description.

.PARAMETER GroupId
The contact group ID.

.PARAMETER Name
The new name for the contact group.

.PARAMETER Privacy
The new privacy level:
1 - Only group members can see the group
2 - Anyone in the organization can see the group
3 - Anyone in the organization can see and join the group

.PARAMETER Description
The new description for the contact group.

.EXAMPLE
Update-ZoomContactGroup -GroupId "abc123" -Name "New Team Name"

.EXAMPLE
Update-ZoomContactGroup -GroupId "abc123" -Privacy 2 -Description "Updated description"

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroupUpdate

#>

function Update-ZoomContactGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('group_id', 'id')]
        [string]$GroupId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 3)]
        [int]$Privacy,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Description
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups/$GroupId"

        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name')) {
            $body.Add('name', $Name)
        }

        if ($PSBoundParameters.ContainsKey('Privacy')) {
            $body.Add('privacy', $Privacy)
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $body.Add('description', $Description)
        }

        if ($body.Count -gt 0) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Patch

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
