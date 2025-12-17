<#

.SYNOPSIS
Create a secondary calendar.

.DESCRIPTION
Creates a new secondary calendar for the authenticated user. Users can create multiple
secondary calendars in addition to their primary calendar.

Prerequisites:
* Calendar API access enabled for your account.

Scopes: calendar:write, calendar:write:admin

.PARAMETER Summary
The title/summary of the calendar.

.PARAMETER Description
A description of the calendar. Optional.

.PARAMETER TimeZone
The time zone of the calendar. Optional.

.PARAMETER Location
The location of the calendar. Optional.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/calendar/methods/#operation/createCalendar

.EXAMPLE
New-ZoomCalendar -Summary 'Project X Calendar'

Create a new secondary calendar with the specified title.

.EXAMPLE
New-ZoomCalendar -Summary 'Team Calendar' -Description 'Shared team events' -TimeZone 'America/New_York'

Create a new calendar with title, description, and time zone.

#>

function New-ZoomCalendar {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('calendar_summary', 'title', 'name')]
        [string]$Summary,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('calendar_description')]
        [string]$Description,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('time_zone', 'tz')]
        [string]$TimeZone,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('calendar_location')]
        [string]$Location
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/calendars"

        if ($PSCmdlet.ShouldProcess($Summary, 'Create Calendar')) {
            $requestBody = @{
                summary = $Summary
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $requestBody.description = $Description
            }

            if ($PSBoundParameters.ContainsKey('TimeZone')) {
                $requestBody.time_zone = $TimeZone
            }

            if ($PSBoundParameters.ContainsKey('Location')) {
                $requestBody.location = $Location
            }

            $requestBody = $requestBody | ConvertTo-Json -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
