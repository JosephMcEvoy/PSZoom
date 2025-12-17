<#

.SYNOPSIS
Create an ACL rule for a calendar.

.DESCRIPTION
Creates a new access control list (ACL) rule for a specified calendar. ACL rules define who has
access to the calendar and what level of access they have.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER Role
The role granted to the scope. Valid values include 'owner', 'writer', 'reader', etc.

.PARAMETER ScopeType
The type of the scope. Valid values include 'user', 'group', 'domain', 'default'.

.PARAMETER ScopeValue
The email address or domain name of the entity to grant access to. Required for 'user', 'group', and 'domain' scope types.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/createCalendarAclRule

.EXAMPLE
New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com'

Grant read access to a specific user for the primary calendar.

.EXAMPLE
New-ZoomCalendarAclRule -CalendarId 'abc123' -Role 'writer' -ScopeType 'group' -ScopeValue 'team@example.com'

Grant write access to a group for a specific calendar.

#>

function New-ZoomCalendarAclRule {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('cal_id', 'calendar_id', 'id')]
        [string]$CalendarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('acl_role')]
        [string]$Role,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('scope_type')]
        [ValidateSet('user', 'group', 'domain', 'default')]
        [string]$ScopeType,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('scope_value')]
        [string]$ScopeValue
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId/acl"

        if ($PSCmdlet.ShouldProcess($CalendarId, 'Create ACL Rule')) {
            $requestBody = @{
                role = $Role
                scope = @{
                    type = $ScopeType
                }
            }

            if ($PSBoundParameters.ContainsKey('ScopeValue')) {
                $requestBody.scope.value = $ScopeValue
            }

            $requestBody = $requestBody | ConvertTo-Json -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
