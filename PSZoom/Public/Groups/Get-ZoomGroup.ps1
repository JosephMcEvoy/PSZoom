<#

.SYNOPSIS
Get a group under your account.
.DESCRIPTION
Get a group under your account.
Prerequisite: Pro, Business, or Education account

.OUTPUTS
Zoom response as an object.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/group
.EXAMPLE
Get-ZoomGroup 24e50639b5bb4fab9c3c

#>

function Get-ZoomGroup  {
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$GroupId"

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        
        Write-Output $response
    }
}