<#

.SYNOPSIS
Get information about a specific shared line group.

.DESCRIPTION
Get information about a specific shared line group on a Zoom Phone account.

.PARAMETER SharedLineGroupId
The unique identifier of the shared line group.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-shared-line-groups/getasharedlinegroup

.EXAMPLE
Get details of a specific shared line group.
Get-ZoomPhoneSharedLineGroup -SharedLineGroupId "abc123xyz"

.EXAMPLE
Get shared line group by ID from pipeline.
"abc123xyz" | Get-ZoomPhoneSharedLineGroup

#>

function Get-ZoomPhoneSharedLineGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('slgId', 'id', 'shared_line_group_id')]
        [string[]]$SharedLineGroupId
     )

    process {
        foreach ($slgId in $SharedLineGroupId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/shared_line_groups/$slgId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
