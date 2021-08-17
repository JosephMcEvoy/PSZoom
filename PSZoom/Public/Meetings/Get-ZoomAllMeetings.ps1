<#
.SYNOPSIS
Get a list of all Zoom meetings in a date range.

.DESCRIPTION
Get a list of all Zoom meetings in a date range.

.PARAMETER Type
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
Note that this uses a heavily rate limited API.
$ids= (Get-ZoomAllMeetings -From 2021-05-01 -To 2021-05-02 -Type past -PageSize 300 -CombineAllPages).meetings.id
$ids | foreach($id in $ids) {
    (Get-ZoomMeetingQoS -MeetingID $_ -Type past -CombineAllPages)
    if ($ids.IndexOf($id) % 10 -eq 0) {Start-Sleep 60}
} | foreach($page)

.OUTPUTS
A hastable with the Zoom API response.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/dashboards/dashboardmeetings

#>

function Get-ZoomAllMeetings {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'CombineAllPages',
            Position = 0
        )]

        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1, 300)]
        [Alias('size', 'page_size')]
        [int]$PageSize = 30,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'CombineAllPages')]
        [string]$NextPageToken,

        [Parameter(
            ParameterSetName = 'CombineAllPages'
        )]
        [switch]$CombineAllPages,

        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$From,

        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$To,

        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page', 'page_number')]
        [int]$PageNumber = 1,

        [ValidateNotNullOrEmpty()]
        [string]$Type,

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

                if ($PSBoundParameters.ContainsKey('From')) {
                    $query.Add('from', $From)
                }

                if ($PSBoundParameters.ContainsKey('To')) {
                    $query.Add('to', $To)
                }

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
            $InitialReport = Get-ZoomAllMeetings -From $From -To $To -PageSize 300 -PageNumber 1 -Type $Type
            $TotalPages = $InitialReport.page_count
            $NextPageToken = $InitialReport.next_page_token
            $CombinedReport = [PSCustomObject]@{
                From                    = $From
                To                      = $To
                page_count              = $InitialReport.page_count
                Total_records           = $InitialReport.total_records
                meetings                = $InitialReport.meetings
            }

            if ($TotalPages -gt 1) {
                for ($i = 1; $i -lt $TotalPages; $i++){
                    $nextReport = Get-ZoomAllMeetings -From $From -To $To -PageSize 300 -Type $Type -NextPageToken $nextPageToken
                    $CombinedReport.meetings += $nextReport.meetings
                    $nextPageToken = $nextReport.next_page_token
                }
            }

            Write-Output $CombinedReport
        }
    }
}