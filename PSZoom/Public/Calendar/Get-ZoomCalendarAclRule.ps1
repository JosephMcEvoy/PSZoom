<#

.SYNOPSIS
Get a specific ACL rule for a calendar.

.DESCRIPTION
Retrieves details of a specific access control list (ACL) rule for a calendar.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER AclId
The ACL rule identifier.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/getCalendarAclRule

.EXAMPLE
Get-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com'

Get details of a specific ACL rule for the primary calendar.

#>

function Get-ZoomCalendarAclRule {
    [CmdletBinding()]
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

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
