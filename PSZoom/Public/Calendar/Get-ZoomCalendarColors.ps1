<#

.SYNOPSIS
Get available calendar colors.

.DESCRIPTION
Retrieves the color palette available for calendars and events. This returns a list of
color definitions that can be used when creating or updating calendars and calendar events.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/getCalendarColors

.EXAMPLE
Get-ZoomCalendarColors

Get the available calendar color palette.

#>

function Get-ZoomCalendarColors {
    [CmdletBinding()]
    param ()

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/colors"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
