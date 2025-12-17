<#

.SYNOPSIS
Add a calendar to a user's calendar list.

.DESCRIPTION
Adds an existing calendar to a user's calendar list. This allows the user to view and manage
the calendar in their calendar interface.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER UserIdentifier
The user identifier. Can be the user ID, email address, or 'me' for the authenticated user.

.PARAMETER CalendarId
The identifier of the calendar to add to the user's calendar list.

.PARAMETER ColorId
The color ID for the calendar entry. Optional.

.PARAMETER Hidden
Whether the calendar is hidden from the list. Optional.

.PARAMETER Selected
Whether the calendar is selected. Optional.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/createUserCalendarListEntry

.EXAMPLE
Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123'

Add a calendar to the authenticated user's calendar list.

.EXAMPLE
Add-ZoomUserCalendarListEntry -UserIdentifier 'user@example.com' -CalendarId 'abc123' -ColorId '1'

Add a calendar with a specific color to a user's calendar list.

#>

function Add-ZoomUserCalendarListEntry {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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
        [string]$CalendarId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('color_id')]
        [string]$ColorId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('is_hidden')]
        [bool]$Hidden,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('is_selected')]
        [bool]$Selected
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/users/$UserIdentifier/calendarList"

        if ($PSCmdlet.ShouldProcess("User: $UserIdentifier, Calendar: $CalendarId", 'Add to Calendar List')) {
            $requestBody = @{
                id = $CalendarId
            }

            if ($PSBoundParameters.ContainsKey('ColorId')) {
                $requestBody.color_id = $ColorId
            }

            if ($PSBoundParameters.ContainsKey('Hidden')) {
                $requestBody.hidden = $Hidden
            }

            if ($PSBoundParameters.ContainsKey('Selected')) {
                $requestBody.selected = $Selected
            }

            $requestBody = $requestBody | ConvertTo-Json -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
