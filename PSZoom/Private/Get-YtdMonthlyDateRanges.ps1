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