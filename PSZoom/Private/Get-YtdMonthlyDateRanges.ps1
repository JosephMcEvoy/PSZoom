. "$PSScriptRoot\Get-DateRanges.ps1"

function Get-YtdMonthlyDateRanges {
    param (
        [datetime]$Date = (Get-Date),
        [string]$Format = 'yyyy-MM-dd'
    )

    $From = (Get-Date -Month 1 -Day 1 -Year $Date.year)
    $Ranges = Get-DateRanges -From $From -To $Date

    Write-Output $Ranges
}