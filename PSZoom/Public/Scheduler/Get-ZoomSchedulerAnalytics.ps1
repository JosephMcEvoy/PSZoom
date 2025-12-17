<#

.SYNOPSIS
Get Scheduler analytics.

.DESCRIPTION
Retrieve analytics data for Zoom Scheduler usage within a specified date range.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:analytics:admin

.PARAMETER From
The query start date, in yyyy-MM-dd'T'HH:mm:ssZ format.

.PARAMETER To
The query end date, in yyyy-MM-dd'T'HH:mm:ssZ format.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getSchedulerAnalytics

.EXAMPLE
Get-ZoomSchedulerAnalytics -From "2024-01-01T00:00:00Z" -To "2024-01-31T23:59:59Z"

Retrieve Scheduler analytics for January 2024.

#>

function Get-ZoomSchedulerAnalytics {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('start_date')]
        [string]$From,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('end_date')]
        [string]$To
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/analytics"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('from', $From)
        $query.Add('to', $To)

        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
