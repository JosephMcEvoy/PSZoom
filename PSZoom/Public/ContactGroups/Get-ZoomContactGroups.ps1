<#

.SYNOPSIS
List contact groups for the current user.

.DESCRIPTION
Returns a list of contact groups belonging to the current user.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 10, max is 50.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets.

.EXAMPLE
Get-ZoomContactGroups

.EXAMPLE
Get-ZoomContactGroups -PageSize 50

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/contactGroups

#>

function Get-ZoomContactGroups {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_size')]
        [ValidateRange(1, 50)]
        [int]$PageSize = 10,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/contacts/groups"
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
