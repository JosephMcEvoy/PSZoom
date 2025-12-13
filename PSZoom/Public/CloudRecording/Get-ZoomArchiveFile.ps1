<#

.SYNOPSIS
List archived files for a meeting or webinar.

.DESCRIPTION
Retrieves archived files for a meeting or webinar. This endpoint lists all archived files of a meeting
or webinar for a specified period of time.

Prerequisites:
* Pro or higher account plan
* Cloud recording must be enabled

Scopes: recording:read:admin, recording:read
Granular Scopes: recording:read:list_archive_files, recording:read:list_archive_files:admin
Rate Limit Label: Medium

.PARAMETER PageSize
The number of records returned within a single API call. Default: 30, Maximum: 300.

.PARAMETER NextPageToken
The next page token paginates through a large set of results.
A next page token is returned whenever the set of available results exceeds the current page size.
The expiration period for this token is 15 minutes.

.PARAMETER QueryDateType
The type of query date. meeting_time, archive_time. Default: meeting_time.

.PARAMETER GroupId
Unique identifier of the group. Get it from the List Groups API.

.PARAMETER GroupIds
Unique identifiers of groups. Get them from the List Groups API.

.PARAMETER From
Start date in 'yyyy-mm-dd' UTC format.

.PARAMETER To
End date in 'yyyy-mm-dd' UTC format.

.OUTPUTS
An object with the Zoom API response containing the archived files.

.EXAMPLE
Get-ZoomArchiveFile

Lists all archived files with default parameters.

.EXAMPLE
Get-ZoomArchiveFile -PageSize 50 -From "2024-01-01" -To "2024-01-31"

Lists archived files for January 2024 with 50 records per page.

.EXAMPLE
Get-ZoomArchiveFile -QueryDateType "archive_time" -GroupId "abc123"

Lists archived files filtered by archive time and group.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listArchivedFiles

#>

function Get-ZoomArchiveFile {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('meeting_time', 'archive_time')]
        [Alias('query_date_type')]
        [string]$QueryDateType,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('group_id')]
        [string]$GroupId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('group_ids')]
        [string[]]$GroupIds,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('from_date')]
        [string]$From,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('to_date')]
        [string]$To
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/archive_files"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($PSBoundParameters.ContainsKey('QueryDateType')) {
            $query.Add('query_date_type', $QueryDateType)
        }

        if ($PSBoundParameters.ContainsKey('GroupId')) {
            $query.Add('group_id', $GroupId)
        }

        if ($PSBoundParameters.ContainsKey('GroupIds')) {
            foreach ($gid in $GroupIds) {
                $query.Add('group_ids', $gid)
            }
        }

        if ($PSBoundParameters.ContainsKey('From')) {
            $query.Add('from', $From)
        }

        if ($PSBoundParameters.ContainsKey('To')) {
            $query.Add('to', $To)
        }

        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
