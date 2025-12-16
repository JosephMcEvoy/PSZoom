<#

.SYNOPSIS
List users in a division.

.DESCRIPTION
Returns a list of all users assigned to a specific division.

.PARAMETER DivisionId
The division ID.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 30, max is 300.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets.

.EXAMPLE
Get-ZoomDivisionMembers -DivisionId "abc123"

.EXAMPLE
Get-ZoomDivisionMembers -DivisionId "abc123" -PageSize 100

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/Listdivisionusers

#>

function Get-ZoomDivisionMembers {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('division_id', 'id')]
        [string]$DivisionId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_size')]
        [ValidateRange(1, 300)]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/divisions/$DivisionId/users"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
