<#

.SYNOPSIS
Get details of a calendar.

.DESCRIPTION
Retrieves metadata and details for a specific calendar. Use 'primary' to get the user's
primary calendar.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/getCalendar

.EXAMPLE
Get-ZoomCalendar -CalendarId 'primary'

Get details of the primary calendar.

.EXAMPLE
Get-ZoomCalendar -CalendarId 'abc123'

Get details of a specific calendar.

#>

function Get-ZoomCalendar {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('cal_id', 'calendar_id', 'id')]
        [string]$CalendarId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
