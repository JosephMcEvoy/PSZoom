<#

.SYNOPSIS
Create a calendar event.

.DESCRIPTION
Creates a new event on a specified calendar. Events can be single occurrences or recurring.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER Summary
The title/summary of the event.

.PARAMETER Description
A description of the event. Optional.

.PARAMETER Location
The location of the event. Optional.

.PARAMETER StartDateTime
The start date and time of the event in RFC3339 format (e.g., 2024-01-01T10:00:00Z).

.PARAMETER StartTimeZone
The time zone for the start time. Optional.

.PARAMETER EndDateTime
The end date and time of the event in RFC3339 format (e.g., 2024-01-01T11:00:00Z).

.PARAMETER EndTimeZone
The time zone for the end time. Optional.

.PARAMETER Attendees
An array of attendee objects with email addresses. Optional.

.PARAMETER Recurrence
An array of recurrence rules (RRULE, EXRULE, RDATE, EXDATE). Optional.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/createCalendarEvent

.EXAMPLE
New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Team Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

Create a simple one-hour event.

.EXAMPLE
$attendees = @(@{email='user1@example.com'}, @{email='user2@example.com'})
New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Project Kickoff' -Description 'Initial planning meeting' -StartDateTime '2024-01-20T10:00:00Z' -EndDateTime '2024-01-20T11:30:00Z' -Location 'Conference Room A' -Attendees $attendees

Create an event with attendees and location.

#>

function New-ZoomCalendarEvent {
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
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_summary', 'title')]
        [string]$Summary,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_description')]
        [string]$Description,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_location')]
        [string]$Location,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('start_date_time', 'start')]
        [string]$StartDateTime,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('start_time_zone', 'start_timezone')]
        [string]$StartTimeZone,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('end_date_time', 'end')]
        [string]$EndDateTime,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('end_time_zone', 'end_timezone')]
        [string]$EndTimeZone,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_attendees')]
        [array]$Attendees,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_recurrence')]
        [array]$Recurrence
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId/events"

        if ($PSCmdlet.ShouldProcess("Calendar: $CalendarId - $Summary", 'Create Event')) {
            $requestBody = @{
                summary = $Summary
                start = @{
                    date_time = $StartDateTime
                }
                end = @{
                    date_time = $EndDateTime
                }
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $requestBody.description = $Description
            }

            if ($PSBoundParameters.ContainsKey('Location')) {
                $requestBody.location = $Location
            }

            if ($PSBoundParameters.ContainsKey('StartTimeZone')) {
                $requestBody.start.time_zone = $StartTimeZone
            }

            if ($PSBoundParameters.ContainsKey('EndTimeZone')) {
                $requestBody.end.time_zone = $EndTimeZone
            }

            if ($PSBoundParameters.ContainsKey('Attendees')) {
                $requestBody.attendees = $Attendees
            }

            if ($PSBoundParameters.ContainsKey('Recurrence')) {
                $requestBody.recurrence = $Recurrence
            }

            $requestBody = $requestBody | ConvertTo-Json -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
