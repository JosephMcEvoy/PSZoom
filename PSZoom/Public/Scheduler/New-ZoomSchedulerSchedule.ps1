<#

.SYNOPSIS
Create a Scheduler schedule.

.DESCRIPTION
Create a new Scheduler schedule template with specified name and type.

Scopes: scheduler:write:admin
Granular Scopes: scheduler:write:schedule:admin

.PARAMETER Name
The name of the schedule template.

.PARAMETER Type
The type of the schedule template.

.PARAMETER Description
The description of the schedule template.

.PARAMETER Duration
The default duration for events using this schedule template, in minutes.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/createSchedulerSchedule

.EXAMPLE
New-ZoomSchedulerSchedule -Name "Standard Meeting" -Type "meeting"

Create a new Scheduler schedule template.

.EXAMPLE
New-ZoomSchedulerSchedule -Name "Weekly Review" -Type "meeting" -Duration 60 -Description "Weekly team review meeting"

Create a new Scheduler schedule template with additional details.

#>

function New-ZoomSchedulerSchedule {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_name')]
        [string]$Name,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_type')]
        [string]$Type,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_description')]
        [string]$Description,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_duration')]
        [int]$Duration
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/schedules"

        $requestBody = @{
            name = $Name
            type = $Type
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $requestBody.Add('description', $Description)
        }

        if ($PSBoundParameters.ContainsKey('Duration')) {
            $requestBody.Add('duration', $Duration)
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

        Write-Output $response
    }
}
