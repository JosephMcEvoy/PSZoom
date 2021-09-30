<#
.SYNOPSIS
Combine all Zoom pages

.DESCRIPTION
Page through all Zoom API results

.PARAMETER ZoomCommand
The PSZoom command you want to run

.PARAMETER ZoomCommandSplat
A PSCustomObject splat of the command parameters

.EXAMPLE
Get all meetings from today that have ended.
$ZoomCommand = "Get-ZoomMeetings"
$ZoomCommandSplat = @{
    From          = $From
    To            = $To
    Type          = "Past"
    PageSize      = 300
}
Join-ZoomPages -ZoomCommand $ZoomCommand -ZoomCommandSplat $ZoomCommandSplat

.OUTPUTS
API response results

#>

function Join-ZoomPages {
    Param (
        [Parameter(
            Mandatory=$true,
            Position = 0
        )]
        [string]$ZoomCommand,
        [Parameter(
            Mandatory=$true,
            Position = 1
        )]
        [Hashtable]$ZoomCommandSplat
    )
    
    $error.clear()
    $InitialReport = &$ZoomCommand @ZoomCommandSplat
    
    # Find relevent member
    foreach ($member in (Get-Member -InputObject $InitialReport -MemberType "NoteProperty").Name) {
        if ($InitialReport.$member.count -gt 1) {
            break
        }
    }
    
    $CombinedReport = $InitialReport.$member
    $ZoomCommandSplat.remove("NextPageToken")
    $NextPageToken = $InitialReport.next_page_token

    if ($InitialReport.page_count -gt 1) {
        for ($i = 1; $i -lt $InitialReport.page_count; $i++){
            $ZoomCommandSplat.add("NextPageToken",$NextPageToken)
	    
            try {
		        $nextReport = &$ZoomCommand @ZoomCommandSplat -erroraction stop
            } catch {
                # HTTP 429 is "Too Many Requests"
                # break
                if ($error[0] -match '429') {
                    $RetryPeriod = 30
                    #If header provides timer interval
                    if ('X-Rate-Limit-Reset' -in $error[0].Exception.Response.Headers)
                    {
                        $RetryPeriod = $error.Exception.Response.Headers.GetValues('X-Rate-Limit-Reset')
                        if ($RetryPeriod -is [string[]])
                        {
                            $RetryPeriod = [int]$RetryPeriod[0]
                        }
                    }
                    # Write Response error
                    Write-Verbose "Sleeping $RetryPeriod seconds due to HTTP 429 response"
                    Start-Sleep -Seconds $RetryPeriod
                    $nextReport = &$ZoomCommand @ZoomCommandSplat
                } else {
                    Write-Error -Exception $_.Exception -Message "API call failed: $error"
                }
            }
	    
            $CombinedReport += $nextReport.$member
            $nextPageToken = $nextReport.next_page_token
            $ZoomCommandSplat.remove("NextPageToken")
            $error.clear()
        }
    }
    Write-Output $CombinedReport
}
