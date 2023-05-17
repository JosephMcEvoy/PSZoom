<#

.SYNOPSIS
Retrieve a telephone report for a specified period of time. 

.DESCRIPTION
Retrieve a telephone report for a specified period of time.

.PARAMETER From
Start date.

.PARAMETER To
End date.

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER PageNumber
The current page number of returned records.

.PARAMETER YearTiDate
Use this switch to automatically retrieve all entries for the calendar year.

.PARAMETER CombineAllPages
If a report has multiple pages this will loop through all pages automatically and place all telephony usage found 
from each page into the telephony_usage field of the report generated. The page size is set automatically to 300.
.PARAMETER Type
Audio types: 1 - Toll-free Call-in & Call-out. The only option is 1. This defaults to 1.
Note that Zoom documents this as a request parameter so it is included here. However it has no practical use at the moment.

.EXAMPLE
Get-ZoomTelephoneReports -from '2019-07-01' -to '2019-07-31' -page 1 -pagesize 300
Get-ZoomTelephoneReports -ytd

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomTelephoneReports {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(ParameterSetName = 'CombineAllPages')]
        [datetime]$From,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(ParameterSetName = 'CombineAllPages')]
        [datetime]$To,

        [Parameter(ParameterSetName = 'CombineAllPages')]
        [switch]$CombineAllPages,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [ValidateRange(1, 300)]
        [Alias('size', 'page_size')]
        [int]$PageSize = 30,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Alias('page', 'page_number')]
        [int]$PageNumber = 1,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(ParameterSetName = 'CombineAllPages')]
        [ValidateSet(1)]
        [int]$Type = 1,

        [Parameter(ParameterSetName = 'YearToDate')]
        [Alias('ytd')]
        [switch]$YearToDate
    )

    begin {
        if ($From) {
            [string]$From = $From.ToString('yyyy-MM-dd')
        }
        if ($To){
            [string]$To = $To.ToString('yyyy-MM-dd')
        }
        
    }

    process {
        if ($PsCmdlet.ParameterSetName -eq 'CombineAllPages') {
                $InitialReport = Get-ZoomTelephoneReports -From $From -To $To -PageSize 300 -PageNumber 1 -Type $Type
                $TotalPages = $InitialReport.page_count
                $CombinedReport = [PSCustomObject]@{
                    From                  = $From
                    To                    = $To
                    Page_count            = $InitialReport.page_count
                    Total_records         = $InitialReport.total_records
                    telephony_usage       = $InitialReport.telephony_usage
                }
    
                if ($TotalPages -gt 1) {
                    for ($i=2; $i -le $TotalPages; $i++){
                        $telephony_usage = (Get-ZoomTelephoneReports -From $From -To $To -PageSize 300 -PageNumber $i -Type $Type).telephony_usage
                        $CombinedReport.telephony_usage += $telephony_usage
                    }
                }
    
                Write-Output $CombinedReport
        } else {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/report/telephone"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('type', $Type)
            $query.Add('from', $From)
            $query.Add('to', $To)
            $query.Add('page_size', $PageSize)
            $query.Add('page_number', $PageNumber)
            $Request.Query = $query.ToString()

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
            
            Write-Output $response
        }
    }
}