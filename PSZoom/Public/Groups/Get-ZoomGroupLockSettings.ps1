<#

.SYNOPSIS
Retrieve a group's locked settings. If you lock a setting, the group memebers will not be able to modify it individually.

.DESCRIPTION
Retrieve a group's locked settings. If you lock a setting, the group memebers will not be able to modify it individually.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
The Zoom response (an object).

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/getgrouplocksettings

.EXAMPLE
Get groups lock settings.
Get-ZoomGroupLockSettings -GroupId (((Get-ZoomGroups) | where-object {$_ -match 'Dark Side'}))

#>

function Get-ZoomGroupLockSettings  {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId/lock_settings"

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret


        Write-Output $response   
    }
}