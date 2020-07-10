. "$PSScriptRoot\Get-DateRanges.ps1"

function Get-LastSixMonthsDateRanges {
    param (
        [string]$Format = 'yyyy-MM-dd'
    )

    $From = (Get-Date).AddMonths(-6).AddDays(2) #Zoom requires that reports are within 6 months. The 2 additional days allow for this.
    $To = (Get-Date)
    $Ranges = Get-DateRanges -From $From -To $To

    Write-Output $Ranges
}