<#

.SYNOPSIS
Update an ACL rule for a calendar.

.DESCRIPTION
Updates an existing access control list (ACL) rule for a calendar. This can be used to change
the role or scope of an existing ACL rule.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER AclId
The ACL rule identifier.

.PARAMETER Role
The role granted to the scope. Valid values include 'owner', 'writer', 'reader', etc.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/updateCalendarAclRule

.EXAMPLE
Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'writer'

Update an ACL rule to change the user's role to writer.

#>

function Update-ZoomCalendarAclRule {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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
        [string]$AclId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('acl_role')]
        [string]$Role
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId/acl/$AclId"

        if ($PSCmdlet.ShouldProcess("Calendar: $CalendarId, ACL: $AclId", 'Update')) {
            $requestBody = @{
                role = $Role
            }

            $requestBody = $requestBody | ConvertTo-Json -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method PATCH

            Write-Output $response
        }
    }
}
