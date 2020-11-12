<#

.EXAMPLE
$AllScheduledMeetings = Get-ZoomAllScheduledMeetings
$NoFixedTimeMeetings = $AllScheduledMeetings | Where-Object type -eq 3
$RecurringMeetings = $AllScheduledMeetings | Where-Object type -eq 8

#>

#requires -modules PSZoom

function Get-ZoomAllScheduledMeetings {
    (Get-ZoomUsers -All | Get-ZoomMeetingsFromUser -type 'scheduled' | Where-Object total_records -gt 0).meetings
}