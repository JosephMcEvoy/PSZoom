<#

.SYNOPSIS
Retrieve an active or inactive host report for a specified period of time. 
.DESCRIPTION
Retrieve an active or inactive host report for a specified period of time. 
The time range for the report is limited to a month and the month should fall under the past six months. 
.PARAMETER Type
Active
Inactive
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
Get-ZoomActiveInactiveHostReport -from '2019-07-01' -to '2019-07-31' -page 1 -pagesize 300
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Get-ZoomActiveInactiveHostReport {
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
        [ValidateSet('active', 'inactive')]
        [string]$Type,

        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/telephone"
        $RequestBody = @{ }
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $Query.Add('from', $From)
        $Query.Add('to', $To)
        $Query.Add('page_size', $PageSize)
        $Query.Add('page_number', $PageNumber)

        if ($PSBoundParameters.ContainsKey('Type')){
            $Query.Add('type', $Type)
        }

        $Request.Query = $Query.ToString()
        
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}

function Get-LastSixMonthsDateRanges {
    param (
        [string]$Format = 'yyyy-MM-dd'
    )

    $Date = (Get-Date)
    $Year = $Date.Year
    $Month = $Date.AddMonths(-6)

    $Ranges = @{}

    while ($Month -lt (Get-Date $Date -day 1)) {
        $Month = $Month.AddMonths(1)

        $Range = @{
            'begin' = Get-Date $Month -Format $Format
            'end'   = Get-Date ($Month.AddDays([DateTime]::DaysInMonth($Month.Year, $Month.Month) - 1)) -Format $Format
        }

        $Ranges.Add((Get-Date $Month -Format MMMMMMMMM), $Range)
    }

    Write-Output $Ranges
}

function Get-ZomLastSixMonthsActiveHostReport {
    $AllReports = @()
    [int]$Requests = 0
    $MonthRanges = (Get-LastSixMonthsDateRanges)

    $AllReports = New-Object System.Collections.Generic.List[System.Object]
    
    foreach ($Key in $MonthRanges.Keys) {
        $TotalPages = (Get-ZoomActiveInactiveHostReport  -from "$($MonthRanges.$Key.begin)" -to "$($MonthRanges.$Key.end)" -pagesize 300 -pagenumber 1 -type 'active').page_count
        
        for ($i = 1; $i -le $TotalPages; $i++) {
            if (($Requests % 12) -eq 0) { #Zoom limits the number of requests per second
                Start-Sleep -seconds 3
            }

            $CurrentPage = (Get-ZoomActiveInactiveHostReport  -from "$($MonthRanges.$Key.begin)" -to "$($MonthRanges.$Key.end)" -pagesize 300 -pagenumber $i -type 'active').telephony_usage
            
            foreach ($Entry in $CurrentPage) {
                $AllReports.Add($Entry)
            }

            $Requests++
        }

        
    }
    write-output $AllReports
}