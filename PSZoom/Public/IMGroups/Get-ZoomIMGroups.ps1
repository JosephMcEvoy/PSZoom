<#

.SYNOPSIS
List IM directory groups under an account.

.DESCRIPTION
List IM directory groups under an account.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 30, max is 300.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets.

.EXAMPLE
Get-ZoomIMGroups

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imGroups

#>

function Get-ZoomIMGroups {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_size')]
        [ValidateRange(1, 300)]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/groups"
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
