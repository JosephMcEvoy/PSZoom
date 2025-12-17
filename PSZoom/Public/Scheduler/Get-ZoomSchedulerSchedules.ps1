<#

.SYNOPSIS
List Scheduler schedules.

.DESCRIPTION
List all Scheduler schedule templates for the account.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:schedule:admin

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken
Use the next page token to paginate through large result sets. A next page token is returned whenever
the set of available results exceeds the current page size. This token's expiration period is 15 minutes.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listSchedulerSchedules

.EXAMPLE
Get-ZoomSchedulerSchedules

List all Scheduler schedules with default parameters.

.EXAMPLE
Get-ZoomSchedulerSchedules -PageSize 50

List Scheduler schedules with a custom page size.

#>

function Get-ZoomSchedulerSchedules {
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/schedules"
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
