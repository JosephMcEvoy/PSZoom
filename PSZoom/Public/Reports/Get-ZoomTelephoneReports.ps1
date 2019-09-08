<#

.SYNOPSIS
Retrieve a telephone report for a specified period of time. 

.DESCRIPTION
Retrieve a telephone report for a specified period of time.

.PARAMETER From
Start date in 'yyyy-mm-dd' format.

.PARAMETER To
End date in 'yyyy-mm-dd' format.

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER PageNumber
The current page number of returned records.

.PARAMETER YearTiDate
Use this switch to automatically retrieve all entries for the calendar year.

.PARAMETER Type
Audio types: 1 - Toll-free Call-in & Call-out. The only option is 1. This defaults to 1.
Note that Zoom documents this as a request parameter so it is included here. However it has no practical use at the moment.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

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
        [ValidatePattern('([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')]
        [string]$From,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [ValidatePattern('([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')]
        [string]$To,

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
        [ValidateSet(1)]
        [int]$Type = 1,

        [Parameter(ParameterSetName = 'YearToDate')]
        [Alias('ytd')]
        [switch]$YearToDate,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        if ($YearToDate) {
                [int]$Requests = 0
                $MonthRanges = (Get-YtdMonthlyDateRanges)
                $AllTelephoneReports = New-Object System.Collections.Generic.List[System.Object]

                foreach ($Key in $MonthRanges.Keys) {
                    $TotalPages = (Get-ZoomTelephoneReports -from "$($MonthRanges.$Key.begin)" -to "$($MonthRanges.$Key.end)" -pagesize 300 -pagenumber 1).page_count
                    
                    for ($i = 1; $i -le $TotalPages; $i++) {
                        if (($Requests % 10) -eq 0) {  #Zoom limits the number of requests to 10 per second
                            Start-Sleep -seconds 2
                        }
            
                        $CurrentPage = (Get-ZoomTelephoneReports -from "$($MonthRanges.$Key.begin)" -to "$($MonthRanges.$Key.end)" -pagesize 300 -pagenumber $i).telephony_usage
                        
                        foreach ($Entry in $CurrentPage) {
                            $AllTelephoneReports.Add($Entry)
                        }
            
                        $Requests++
                    }
                }
                write-output $AllTelephoneReports
        } else {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/telephone"
            $RequestBody = @{ }
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $Query.Add('type', $Type)
            $Query.Add('from', $From)
            $Query.Add('to', $To)
            $Query.Add('page_size', $PageSize)
            $Query.Add('page_number', $PageNumber)
            $Request.Query = $Query.ToString()

            try {
                $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method GET
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            }
            
            Write-Output $Response
        }
    }
}