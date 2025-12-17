<#

.SYNOPSIS
List calendars in a user's calendar list.

.DESCRIPTION
Retrieves the list of calendars for a specified user. This returns all calendars that the user
has added to their calendar list, including their primary calendar and any secondary calendars.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:read, calendar:read:admin

.PARAMETER UserIdentifier
The user identifier. Can be the user ID, email address, or 'me' for the authenticated user.

.PARAMETER PageSize
The number of records returned within a single API call. Maximum 300.

.PARAMETER NextPageToken
Use the next page token to paginate through large result sets. A next page token is returned whenever
the set of available results exceeds the current page size.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/listUserCalendarList

.EXAMPLE
Get-ZoomUserCalendarList -UserIdentifier 'me'

List all calendars for the authenticated user.

.EXAMPLE
Get-ZoomUserCalendarList -UserIdentifier 'user@example.com' -PageSize 50

List calendars for a specific user with custom page size.

#>

function Get-ZoomUserCalendarList {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_identifier', 'user_id', 'user', 'id')]
        [string]$UserIdentifier,

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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars/users/$UserIdentifier/calendarList"
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
