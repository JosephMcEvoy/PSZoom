<#

.SYNOPSIS
Get a specific calendar from a user's calendar list.

.DESCRIPTION
Retrieves details of a specific calendar from a user's calendar list.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.PARAMETER UserIdentifier
The user identifier. Can be the user ID, email address, or 'me' for the authenticated user.

.PARAMETER CalendarId
The calendar identifier.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/getUserCalendarListEntry

.EXAMPLE
Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'primary'

Get the primary calendar from the authenticated user's calendar list.

.EXAMPLE
Get-ZoomUserCalendarListEntry -UserIdentifier 'user@example.com' -CalendarId 'abc123'

Get a specific calendar from a user's calendar list.

#>

function Get-ZoomUserCalendarListEntry {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_identifier', 'user_id', 'user')]
        [string]$UserIdentifier,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('calendar_id', 'id')]
        [string]$CalendarId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/users/$UserIdentifier/calendarList/$CalendarId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
