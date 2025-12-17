<#

.SYNOPSIS
Update a Scheduler availability.

.DESCRIPTION
Update an existing Scheduler availability configuration with new name and/or schedule.

Scopes: scheduler:write:admin
Granular Scopes: scheduler:write:availability:admin

.PARAMETER AvailabilityId
The Scheduler availability ID.

.PARAMETER Name
The name of the availability configuration.

.PARAMETER Schedule
The schedule configuration object. This should be a hashtable or object containing the schedule details.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateSchedulerAvailability

.EXAMPLE
$schedule = @{
    timezone = "America/New_York"
    days = @(
        @{ day = "Monday"; intervals = @(@{ from = "09:00"; to = "17:00" }) }
    )
}
Update-ZoomSchedulerAvailability -AvailabilityId "abc123" -Name "Updated Work Hours" -Schedule $schedule

Update a Scheduler availability configuration.

#>

function Update-ZoomSchedulerAvailability {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('availability_id', 'id')]
        [string]$AvailabilityId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('availability_name')]
        [string]$Name,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_config')]
        [object]$Schedule
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/availability/$AvailabilityId"

        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('Name')) {
            $requestBody.Add('name', $Name)
        }

        if ($PSBoundParameters.ContainsKey('Schedule')) {
            $requestBody.Add('schedule', $Schedule)
        }

        if ($requestBody.Count -eq 0) {
            Write-Warning "No update parameters specified. No changes will be made."
            return
        }

        if ($PSCmdlet.ShouldProcess($AvailabilityId, "Update Scheduler Availability")) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method PATCH

            Write-Output $response
        }
    }
}
