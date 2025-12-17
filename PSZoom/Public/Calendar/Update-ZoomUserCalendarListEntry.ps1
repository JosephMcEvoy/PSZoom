<#

.SYNOPSIS
Update a calendar in a user's calendar list.

.DESCRIPTION
Updates properties of a calendar in a user's calendar list, such as color, visibility, and selection status.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER UserIdentifier
The user identifier. Can be the user ID, email address, or 'me' for the authenticated user.

.PARAMETER CalendarId
The calendar identifier.

.PARAMETER ColorId
The color ID for the calendar entry.

.PARAMETER Hidden
Whether the calendar is hidden from the list.

.PARAMETER Selected
Whether the calendar is selected.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/updateUserCalendarListEntry

.EXAMPLE
Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5'

Update the color of a calendar in the user's calendar list.

.EXAMPLE
Update-ZoomUserCalendarListEntry -UserIdentifier 'user@example.com' -CalendarId 'abc123' -Hidden $false -Selected $true

Update visibility and selection status of a calendar.

#>

function Update-ZoomUserCalendarListEntry {
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/users/$UserIdentifier/calendarList/$CalendarId"

        if ($PSCmdlet.ShouldProcess("User: $UserIdentifier, Calendar: $CalendarId", 'Update Calendar List Entry')) {
            $requestBody = @{}

            if ($PSBoundParameters.ContainsKey('ColorId')) {
                $requestBody.color_id = $ColorId
            }

            if ($PSBoundParameters.ContainsKey('Hidden')) {
                $requestBody.hidden = $Hidden
            }

            if ($PSBoundParameters.ContainsKey('Selected')) {
                $requestBody.selected = $Selected
            }

            $requestBody = $requestBody | ConvertTo-Json

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method PATCH

            Write-Output $response
        }
    }
}
