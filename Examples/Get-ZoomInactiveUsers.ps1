<#

.SYNOPSIS
Get inactive hosts and users who have not used telephony actively.

.DESCRIPTION
Get inactive hosts and users who have not used telephony actively. A user logging on to account is
not considered active. This cmdlet compares those users who have not hosted a meeting in Zoom and have
not used Zoom for telephone only meetings for the entire provided time period.

.PARAMETER FROM
The start date in 'yyyy-MM-dd' format. Zoom limits the reports to the last 6 months. 
Default is 6 months from current day.

.PARAMETER To
The end date in 'yyyy-MM-dd' format. Default is the current date.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS

.LINK

.EXAMPLE
Get-ZoomInactiveUsers -From (Get-date).AddDays(-30)

#>

#requires -modules PSZoom

function Get-ZoomInactiveUsers {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('StartDate')]
        [DateTime]$From = ((Get-Date).AddMonths(-6).AddDays(1)), #Six months. Max time span per Zoom API Docs.
        

        [Alias('EndDate')]
        [DateTime]$To = (Get-Date)
    )

    process {
        #Host Reports
        $monthRanges = Get-DateRanges -From $From -To $To
        $hostReport = (Get-ZoomActiveInactiveHostReports -From $monthRanges[0].begin -To $monthRanges[0].end -Type inactive -CombineAllPages).users
    
        foreach ($month in $monthRanges.keys) {
            if ($month -ne $monthRanges.keys[0]) {
                $users = (Get-ZoomActiveInactiveHostReports -From $monthRanges.$month.begin -To $monthRanges.$month.end -Type inactive -CombineAllPages).users
                $nextHostReport = New-Object System.Collections.Generic.List[System.Object]
        
                foreach ($user in $users) {
                    if ($user.email -in $hostReport.email) {
                        $nextHostReport += $user
                    }
                }
                
                $hostReport = $nextHostReport
            }
        }
        
        #Telephony Reports
        $allTelephonyReportsCombined = @()
    
        foreach ($month in $monthRanges.keys) {
                $allTelephonyReportsCombined += (Get-ZoomTelephoneReports -From $monthRanges.$month.begin -To $monthRanges.$month.end -CombineAllPages).telephony_usage
        }

        $AllTelephonyReportsCombined = $AllTelephonyReportsCombined | 
        Sort-Object -Property @{Expression = "host_email"; Descending = $False}, @{Expression = "start_time"; Descending = $True}
        $telephonyUserEmails = $AllTelephonyReportsCombined.host_Email | Get-Unique
        $inactiveHostEmails = $hostReport.email
        $inactiveUsers = @()
#
        foreach ($email in $inactiveHostEmails) {
            if ($email -notin $telephonyUserEmails) {
                $inactiveUsers += $email
            }
        }

        Write-Output $telephonyUserEmails
    }
}

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