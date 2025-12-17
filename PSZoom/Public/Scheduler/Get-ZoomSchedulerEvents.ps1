<#

.SYNOPSIS
List Scheduler events.

.DESCRIPTION
List all Scheduler events for the account, with optional filtering by status.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:event:admin

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken
Use the next page token to paginate through large result sets. A next page token is returned whenever
the set of available results exceeds the current page size. This token's expiration period is 15 minutes.

.PARAMETER Status
Filter events by status. Valid values include 'pending', 'confirmed', 'cancelled', etc.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listSchedulerEvents

.EXAMPLE
Get-ZoomSchedulerEvents

List all Scheduler events with default parameters.

.EXAMPLE
Get-ZoomSchedulerEvents -Status "confirmed" -PageSize 50

List confirmed Scheduler events with a custom page size.

#>

function Get-ZoomSchedulerEvents {
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
        [string]$NextPageToken,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_status')]
        [string]$Status
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/events"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('PageSize')) {
            $query.Add('page_size', $PageSize)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($PSBoundParameters.ContainsKey('Status')) {
            $query.Add('status', $Status)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
