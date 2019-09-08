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