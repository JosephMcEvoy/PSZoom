<#

.SYNOPSIS
Delete a secondary calendar.

.DESCRIPTION
Deletes a secondary calendar. The primary calendar cannot be deleted.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER CalendarId
The calendar identifier. Cannot be 'primary'.

.OUTPUTS
System.Boolean

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/deleteCalendar

.EXAMPLE
Remove-ZoomCalendar -CalendarId 'abc123'

Delete a secondary calendar.

#>

function Remove-ZoomCalendar {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
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
        if ($CalendarId -eq 'primary') {
            Write-Error "Cannot delete the primary calendar."
            return
        }

        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId"

        if ($PSCmdlet.ShouldProcess($CalendarId, 'Remove')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE
            Write-Verbose "Calendar $CalendarId deleted."
            Write-Output $true
        }
    }
}
