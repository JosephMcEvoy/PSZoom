<#

.SYNOPSIS
Remove a calendar from a user's calendar list.

.DESCRIPTION
Removes a calendar from a user's calendar list. This does not delete the calendar itself,
only removes it from the user's list.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER UserIdentifier
The user identifier. Can be the user ID, email address, or 'me' for the authenticated user.

.PARAMETER CalendarId
The calendar identifier.

.OUTPUTS
System.Boolean

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/deleteUserCalendarListEntry

.EXAMPLE
Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123'

Remove a calendar from the authenticated user's calendar list.

.EXAMPLE
Remove-ZoomUserCalendarListEntry -UserIdentifier 'user@example.com' -CalendarId 'abc123'

Remove a calendar from a specific user's calendar list.

#>

function Remove-ZoomUserCalendarListEntry {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
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

        if ($PSCmdlet.ShouldProcess("User: $UserIdentifier, Calendar: $CalendarId", 'Remove from Calendar List')) {
            $null = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE
            Write-Verbose "Calendar $CalendarId removed from user $UserIdentifier's calendar list."
            Write-Output $true
        }
    }
}
