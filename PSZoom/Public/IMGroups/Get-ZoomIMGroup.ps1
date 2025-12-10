<#

.SYNOPSIS
Retrieve an IM directory group under an account.

.DESCRIPTION
Retrieve an IM directory group under an account.

.PARAMETER GroupId
The group ID.

.EXAMPLE
Get-ZoomIMGroup -GroupId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imGroup

#>

function Get-ZoomIMGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'group_id')]
        [string]$GroupId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/im/groups/$GroupId"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
