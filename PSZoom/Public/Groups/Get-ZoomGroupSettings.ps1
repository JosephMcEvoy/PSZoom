<#

.SYNOPSIS
Get settings for a group.

.DESCRIPTION
Get settings for a group.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.OUTPUTS
The Zoom response (an object).

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/getgroupsettings

.EXAMPLE
Get a group's settings.
Get-ZoomGroups | where-object {$_ -match 'Dark Side'} | Get-ZoomGroupSettings

#>

function Get-ZoomGroupSettings  {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$GroupId/settings"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        Write-Output $response   
    }
}