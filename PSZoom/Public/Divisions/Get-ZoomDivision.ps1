<#

.SYNOPSIS
Get a specific division.

.DESCRIPTION
Returns information about a specific division under an account.

.PARAMETER DivisionId
The division ID.

.EXAMPLE
Get-ZoomDivision -DivisionId "abc123"

.EXAMPLE
"abc123" | Get-ZoomDivision

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/Getdivision

#>

function Get-ZoomDivision {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('division_id', 'id')]
        [string]$DivisionId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/divisions/$DivisionId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
