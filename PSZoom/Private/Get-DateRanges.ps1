<#

.SYNOPSIS
Returns begin and end dates for each month respective of start and end dates.

.DESCRIPTION
Returns begin and end dates for each month respective of start and end dates. This is used because Zoom reports 
limits each report to a month long. Using this you can generate a list of dates given a time frame, then loop over 
the dates to generate a report for each month.

.PARAMETER From
The start date.

.PARAMETER To
The end date.

.PARAMETER Format
The format of the date values in the output. Default is yyyy-MM-dd (what Zoom uses).

.EXAMPLE
Get date ranges from 2020-04-01 to 2020-06-10.
Get-DateRanges -From 2020-04-01 -To 2020-06-10

Returns a PowerShell object that looks like the following:
@{
  "042020": {
    "begin": "2020-04-01",
    "end": "2020-04-30"
  },
  "052020": {
    "begin": "2020-06-01",
    "end": "2020-06-10"
  },
  "062020": {
    "begin": "2020-05-01",
    "end": "2020-05-31"
  }
}

.EXAMPLE
Get the last 6 months date ranges.
$From = (Get-Date ((Get-Date).AddMonths(-6)) -Format 'yyyy-MM-dd')
$To = (Get-Date -Format 'yyyy-MM-dd')
$Ranges = Get-Date Ranges -From $From -To $To

#>

function Get-DateRanges {
    param (
        [Parameter(
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('StartDate')]
        [datetime]$From,

        [Parameter(
            Position = 1, 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('EndDate')]
        [datetime]$To,

        [Parameter(
            Position = 2, 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Format = 'yyyy-MM-dd'
    )

    $ranges = [ordered]@{}

    while ($From -le (Get-Date $To)) {
        $range = @{
            'begin' = Get-Date $From -Format $Format
        }

        $end = (Get-Date ($From.AddDays([DateTime]::DaysInMonth($From.year, $From.month) - 1)) -Format $Format) #Returns last day in a month as Date Time

        if ($To -lt $end) {
            $range.Add('end', (Get-Date $To -Format $Format))
        } else {
            $range.Add('end', $end)
        }

        $ranges.Add((Get-Date $From -Format MMyyyy), $range)
        $From = $From.AddMonths(1)
    }

    Write-Output $Ranges
}