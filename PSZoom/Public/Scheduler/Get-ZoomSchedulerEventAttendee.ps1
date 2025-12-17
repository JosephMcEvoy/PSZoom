<#

.SYNOPSIS
Get a Scheduler event attendee.

.DESCRIPTION
Retrieve details of a specific attendee for a Scheduler event.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:event_attendee:admin

.PARAMETER EventId
The Scheduler event ID.

.PARAMETER AttendeeId
The attendee ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getSchedulerEventAttendee

.EXAMPLE
Get-ZoomSchedulerEventAttendee -EventId "abc123" -AttendeeId "xyz789"

Retrieve details of a specific attendee for a Scheduler event.

#>

function Get-ZoomSchedulerEventAttendee {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('event_id')]
        [string]$EventId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('attendee_id')]
        [string]$AttendeeId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/events/$EventId/attendees/$AttendeeId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
