<#

.SYNOPSIS
List Scheduler availabilities.

.DESCRIPTION
List all Scheduler availability configurations for the account.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:availability:admin

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken
Use the next page token to paginate through large result sets. A next page token is returned whenever
the set of available results exceeds the current page size. This token's expiration period is 15 minutes.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listSchedulerAvailabilities

.EXAMPLE
Get-ZoomSchedulerAvailabilities

List all Scheduler availabilities with default parameters.

.EXAMPLE
Get-ZoomSchedulerAvailabilities -PageSize 50

List Scheduler availabilities with a custom page size.

#>

function Get-ZoomSchedulerAvailabilities {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page_size')]
        [ValidateRange(1, 100)]
        [int]$PageSize,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/availability"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('PageSize')) {
            $query.Add('page_size', $PageSize)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
