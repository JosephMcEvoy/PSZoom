<#
.SYNOPSIS
Get a list of all Zoom meetings in a date range.

.DESCRIPTION
Get a list of all Zoom meetings in a date range.

.PARAMETER Type
Specify a value to get the response for the corresponding meeting type. The default value is 'live'.
The value of this field can be one of the following:
past - Meetings that already occurred in the specified date range.
pastOne - Past meetings that were attended by only one user.
live - Live meetings.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 30.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the 
set of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER CombineAllPages
If a report has multiple pages this will loop through all pages automatically and place all participants found from 
each page into the Participants field of the report generated. The page size is set automatically to 300. The next 
page token is automatically passed from page to page.

.PARAMETER From
The start date for the monthly range for which you would like to retrieve recordings. The maximum range can be 
a month. The month should fall within the past six months period from the date of query.

.PARAMETER To
The end date for the monthly range for which you would like to retrieve recordings. The maximum range can be a 
month. The month should fall within the past six months period from the date of query.

.EXAMPLE
Get the first page returned for all current meetings.
(Get-ZoomMeetings).meetings

.EXAMPLE
Get all meetings from today that have ended.
(Get-ZoomMeetings -CombineAllPages -Type past).meetings

.EXAMPLE
Get all Zoom Meetings that happened from 2021-05-01 to 2021-05-10.
(Get-ZoomMeetings -From 2021-05-01 -To 2021-05-02 -Type past -PageSize 300 -CombineAllPages).meetings

.EXAMPLE
Get last 30 days of past Zoom meetings.
(Get-ZoomMeetings -From (Get-date).addDays(-30) -Type past -PageSize 300 -CombineAllPages).meetings

.OUTPUTS
A hastable with the Zoom API response.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/dashboards/dashboardmeetings

#>

function Get-ZoomMeetings {
    [CmdletBinding(DefaultParameterSetName = 'Default')]

    param (
        [Parameter(
            ParameterSetName = 'CombineAllPages',
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateRange(1, 300)]
        [Alias('size', 'page_size')]
        [int]$PageSize = 30,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'CombineAllPages')]
        [string]$NextPageToken,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = 'CombineAllPages'
        )]
        [switch]$CombineAllPages,

        [datetime]$From = (Get-Date),

        [datetime]$To = (Get-Date),

        [ValidateSet('past','pastOne','live')]
        [string]$Type = 'live',

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        if ($PsCmdlet.ParameterSetName -eq 'Default') {
                $Request = [System.UriBuilder]"https://api.zoom.us/v2/metrics/meetings"
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                $query.Add('page_size', $PageSize)
                $query.Add('type', $Type)

                [string]$From = (Get-Date $From -Format 'yyyy-MM-dd')
                $query.Add('from', $From)

                [string]$To = (Get-Date $To -Format 'yyyy-MM-dd')
                $query.Add('to', $To.toString())

                if ($NextPageToken) {
                    $query.Add('next_page_token', $NextPageToken)
                }

                $Request.Query = $query.ToString()

                try {
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
                } catch {
                    Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
                }

                Write-Output $response
                
        } elseif ($PsCmdlet.ParameterSetName -eq 'CombineAllPages') {
            $InitialReport = Get-ZoomMeetings -From $From -To $To -PageSize 300 -Type $Type
            $TotalPages = $InitialReport.page_count
            $NextPageToken = $InitialReport.next_page_token
            $CombinedReport = [PSCustomObject]@{
                From          = $From
                To            = $To
                page_count    = $InitialReport.page_count
                Total_records = $InitialReport.total_records
                meetings      = $InitialReport.meetings
            }

            if ($TotalPages -gt 1) {
                for ($i = 1; $i -lt $TotalPages; $i++){
                    $nextReport = Get-ZoomMeetings -From $From -To $To -PageSize 300 -Type $Type -NextPageToken $nextPageToken
                    $CombinedReport.meetings += $nextReport.meetings
                    $nextPageToken = $nextReport.next_page_token
                }
            }

            Write-Output $CombinedReport
        }
    }
}