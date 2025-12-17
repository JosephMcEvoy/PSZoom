<#

.SYNOPSIS
List ACL rules for a calendar.

.DESCRIPTION
Retrieves the access control list (ACL) rules for a specified calendar. ACL rules define who has
access to the calendar and what level of access they have.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.PARAMETER CalendarId
The calendar identifier. Use 'primary' for the primary calendar.

.PARAMETER PageSize
The number of records returned within a single API call. Maximum 300.

.PARAMETER NextPageToken
Use the next page token to paginate through large result sets. A next page token is returned whenever
the set of available results exceeds the current page size.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/listCalendarAcl

.EXAMPLE
Get-ZoomCalendarAcl -CalendarId 'primary'

List all ACL rules for the primary calendar.

.EXAMPLE
Get-ZoomCalendarAcl -CalendarId 'abc123' -PageSize 50

List ACL rules for a specific calendar with custom page size.

#>

function Get-ZoomCalendarAcl {
    [CmdletBinding()]
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
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page_size')]
        [ValidateRange(1, 300)]
        [int]$PageSize,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/$CalendarId/acl"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('PageSize')) {
            $query.Add('page_size', $PageSize)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
