<#

.SYNOPSIS
List events on a calendar.

.DESCRIPTION
Retrieves a list of events from a specified calendar. Results can be filtered by time range
and limited by page size.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER TimeMin
Lower bound (inclusive) for an event's end time to filter by. Must be an RFC3339 timestamp
with mandatory time zone offset, e.g., 2023-01-01T00:00:00Z.

.PARAMETER TimeMax
Upper bound (exclusive) for an event's start time to filter by. Must be an RFC3339 timestamp
with mandatory time zone offset, e.g., 2023-12-31T23:59:59Z.

.PARAMETER MaxResults
Maximum number of events returned on one result page. Default is 250.

.PARAMETER PageToken
Token specifying which result page to return.

.PARAMETER SingleEvents
Whether to expand recurring events into instances and only return single one-off events
and instances of recurring events.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/listCalendarEvents

.EXAMPLE
Get-ZoomCalendarEvents -CalendarId 'primary'

List all events on the primary calendar.

.EXAMPLE
Get-ZoomCalendarEvents -CalendarId 'primary' -TimeMin '2024-01-01T00:00:00Z' -TimeMax '2024-01-31T23:59:59Z'

List events within a specific date range.

.EXAMPLE
Get-ZoomCalendarEvents -CalendarId 'abc123' -MaxResults 50 -SingleEvents $true

List up to 50 single events, expanding recurring events into instances.

#>

function Get-ZoomCalendarEvents {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('cal_id', 'calendar_id', 'id')]
        [string]$CalendarId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('time_min')]
        [string]$TimeMin,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('time_max')]
        [string]$TimeMax,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('max_results')]
        [ValidateRange(1, 2500)]
        [int]$MaxResults,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page_token')]
        [string]$PageToken,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('single_events')]
        [bool]$SingleEvents
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId/events"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('TimeMin')) {
            $query.Add('time_min', $TimeMin)
        }

        if ($PSBoundParameters.ContainsKey('TimeMax')) {
            $query.Add('time_max', $TimeMax)
        }

        if ($PSBoundParameters.ContainsKey('MaxResults')) {
            $query.Add('max_results', $MaxResults)
        }

        if ($PSBoundParameters.ContainsKey('PageToken')) {
            $query.Add('page_token', $PageToken)
        }

        if ($PSBoundParameters.ContainsKey('SingleEvents')) {
            $query.Add('single_events', $SingleEvents.ToString().ToLower())
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
