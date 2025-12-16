<#

.SYNOPSIS
Get a specific contact group.

.DESCRIPTION
Returns information about a specific contact group.

.PARAMETER GroupId
The contact group ID.

.EXAMPLE
Get-ZoomContactGroup -GroupId "abc123"

.EXAMPLE
"abc123" | Get-ZoomContactGroup

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroup

#>

function Get-ZoomContactGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('group_id', 'id')]
        [string]$GroupId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups/$GroupId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
