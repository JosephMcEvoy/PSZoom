<#

.SYNOPSIS
Retrieve a telephone report for a specified period of time. 
.DESCRIPTION
Retrieve a telephone report for a specified period of time. Please note: the “Toll Report” option will be removed.
.PARAMETER Type
Audio types:
1 - Toll-free Call-in & Call-out.
.PARAMETER From
Start date in 'yyyy-mm-dd' format.
.PARAMETER To
End date.
.PARAMETER PageSize
The number of records returned within a single API call.
.PARAMETER PageNumber
The current page number of returned records.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomTelephoneReports -from '2019-07-01' -to '2019-07-31' -page 1 -pagesize 300
.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomTelephoneReports {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidatePattern('([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')]
        [string]$From,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidatePattern('([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')]
        [string]$To,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1, 300)]
        [Alias('size', 'page_size')]
        [int]$PageSize = 30,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page', 'page_number')]
        [int]$PageNumber = 1,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet(1)]
        [int]$Type = 1,

        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
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

function Get-YtdMonthlyDateRanges {
    param (
        [datetime]$Date = (Get-Date),
        [string]$Format = 'yyyy-MM-dd'
    )

    $Year = $Date.Year

    $Month = Get-Date -Month 12 -Day 1 -Year ($Year-1)

    $Ranges = @{}

    while ($Month -lt (Get-Date $Date -day 1)) {
        $Month = $Month.AddMonths(1)

        $Range = @{
            'begin' = Get-Date $Month -Format $Format
            'end'   = Get-Date ($Month.AddDays([DateTime]::DaysInMonth($Year, $Month.Month) - 1)) -Format $Format
        }

        $Ranges.Add((Get-Date $Month -Format MMMMMMMMM), $Range)
    }

    Write-Output $Ranges
}

function Get-YtdTelephoneReports {
    $AllTelephoneReports = @()
    [int]$Requests = 0
    $MonthRanges = (Get-YtdMonthlyDateRanges)

    $AllTelephoneReports = New-Object System.Collections.Generic.List[System.Object]
    foreach ($Key in $MonthRanges.Keys) {
        $TotalPages = (Get-ZoomTelephoneReports -from "$($MonthRanges.$Key.begin)" -to "$($MonthRanges.$Key.end)" -pagesize 300 -pagenumber 1).page_count
        
        for ($i = 1; $i -le $TotalPages; $i++) {
            if (($Requests % 12) -eq 0) { #Zoom limits the number of requests per second
                Start-Sleep -seconds 3
            }

            $CurrentPage = (Get-ZoomTelephoneReports -from "$($MonthRanges.$Key.begin)" -to "$($MonthRanges.$Key.end)" -pagesize 300 -pagenumber $i).telephony_usage
            
            foreach ($Entry in $CurrentPage) {
                $AllTelephoneReports.Add($Entry)
            }

            $Requests++
        }

        
    }
    write-output $AllTelephoneReports
}