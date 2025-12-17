<#

.SYNOPSIS
Create a Scheduler availability.

.DESCRIPTION
Create a new Scheduler availability configuration with specified name and schedule.

Scopes: scheduler:write:admin
Granular Scopes: scheduler:write:availability:admin

.PARAMETER Name
The name of the availability configuration.

.PARAMETER Schedule
The schedule configuration object. This should be a hashtable or object containing the schedule details.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/createSchedulerAvailability

.EXAMPLE
$schedule = @{
    timezone = "America/New_York"
    days = @(
        @{ day = "Monday"; intervals = @(@{ from = "09:00"; to = "17:00" }) }
    )
}
New-ZoomSchedulerAvailability -Name "Work Hours" -Schedule $schedule

Create a new Scheduler availability configuration.

#>

function New-ZoomSchedulerAvailability {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('availability_name')]
        [string]$Name,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_config')]
        [object]$Schedule
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/availability"

        $requestBody = @{
            name     = $Name
            schedule = $Schedule
        }

        if ($PSCmdlet.ShouldProcess($Name, "Create Scheduler Availability")) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
