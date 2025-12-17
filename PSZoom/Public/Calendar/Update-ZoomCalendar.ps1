<#

.SYNOPSIS
Update a calendar's metadata.

.DESCRIPTION
Updates metadata for a calendar, such as its summary, description, time zone, and location.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER Summary
The title/summary of the calendar.

.PARAMETER Description
A description of the calendar.

.PARAMETER TimeZone
The time zone of the calendar.

.PARAMETER Location
The location of the calendar.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/updateCalendar

.EXAMPLE
Update-ZoomCalendar -CalendarId 'primary' -Summary 'My Updated Calendar'

Update the summary of the primary calendar.

.EXAMPLE
Update-ZoomCalendar -CalendarId 'abc123' -Description 'Updated description' -TimeZone 'America/Los_Angeles'

Update description and time zone of a calendar.

#>

function Update-ZoomCalendar {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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
        [Alias('calendar_summary', 'title', 'name')]
        [string]$Summary,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('calendar_description')]
        [string]$Description,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('time_zone', 'tz')]
        [string]$TimeZone,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('calendar_location')]
        [string]$Location
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId"

        if ($PSCmdlet.ShouldProcess($CalendarId, 'Update')) {
            $requestBody = @{}

            if ($PSBoundParameters.ContainsKey('Summary')) {
                $requestBody.summary = $Summary
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $requestBody.description = $Description
            }

            if ($PSBoundParameters.ContainsKey('TimeZone')) {
                $requestBody.time_zone = $TimeZone
            }

            if ($PSBoundParameters.ContainsKey('Location')) {
                $requestBody.location = $Location
            }

            $requestBody = $requestBody | ConvertTo-Json

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method PATCH

            Write-Output $response
        }
    }
}
