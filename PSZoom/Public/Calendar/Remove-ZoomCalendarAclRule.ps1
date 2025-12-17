<#

.SYNOPSIS
Delete an ACL rule from a calendar.

.DESCRIPTION
Deletes a specific access control list (ACL) rule from a calendar. This removes the specified
user, group, or domain's access to the calendar.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER AclId
The ACL rule identifier.

.OUTPUTS
System.Boolean

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/deleteCalendarAclRule

.EXAMPLE
Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com'

Remove a specific ACL rule from the primary calendar.

#>

function Remove-ZoomCalendarAclRule {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('cal_id', 'calendar_id')]
        [string]$CalendarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('acl_id', 'id')]
        [string]$AclId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId/acl/$AclId"

        if ($PSCmdlet.ShouldProcess("Calendar: $CalendarId, ACL: $AclId", 'Remove')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE
            Write-Verbose "ACL rule $AclId removed from calendar $CalendarId."
            Write-Output $true
        }
    }
}
