<#

.SYNOPSIS
Get participant report for a past meeting
.DESCRIPTION
Get participant report for a past meeting

.PARAMETER MeetingId
The meeting ID.

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken 
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER CombineAllPages
If a report has multiple pages this will loop through all pages automatically and place all participants found from 
each page into the Participants field of the report generated. The page size is set automatically to 300. The next 
page token is automatically passed from page to page.

.EXAMPLE
Tabulate through each page with NextPageToken and export participants to CSV.

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomMeetingParticipantsReport {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default',
            Position = 0
        )]
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'CombineAllPages',
            Position = 0
        )]
        [Alias('id')]
        [string[]]$MeetingId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default',
            Position = 1
        )]
        [ValidateRange(1,300)]
        [int]$PageSize = 30,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default',
            Position = 2
        )]
        [string]$NextPageToken,

        [Parameter(
            ParameterSetName = 'CombineAllPages'
        )]
        [switch]$CombineAllPages
    )

    process {
        if ($PsCmdlet.ParameterSetName -eq 'Default') {
            foreach ($id in $MeetingId) {
                $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/meetings/$MeetingId/participants"
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
                $query.Add('page_size', $PageSize)
                $query.Add('next_page_token', $NextPageToken)
                $Request.Query = $query.ToString()

                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
                
                Write-Output $response
            }
        } elseif ($PsCmdlet.ParameterSetName -eq 'CombineAllPages') {
            $report = Get-ZoomMeetingParticipantsReport -MeetingId $MeetingId -PageSize 300
            $participants = $report.participants
            $nextPageToken = $report.next_page_token

            for ($i = 1; $i -lt $report.page_count; $i++) {
                $nextReport = Get-ZoomMeetingParticipantsReport -MeetingId $MeetingId -PageSize 300 -NextPageToken $nextPageToken
                $participants += $nextReport.participants
                $nextPageToken = $nextReport.next_page_token
            }

            $report.participants = $participants

            Write-Output $report
        }
    }
}