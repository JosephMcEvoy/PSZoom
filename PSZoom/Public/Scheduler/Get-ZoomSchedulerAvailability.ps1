<#

.SYNOPSIS
Get a Scheduler availability.

.DESCRIPTION
Retrieve a specific Scheduler availability configuration by ID.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:availability:admin

.PARAMETER AvailabilityId
The Scheduler availability ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getSchedulerAvailability

.EXAMPLE
Get-ZoomSchedulerAvailability -AvailabilityId "abc123"

Retrieve details of a specific Scheduler availability.

#>

function Get-ZoomSchedulerAvailability {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('availability_id', 'id')]
        [string]$AvailabilityId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/availability/$AvailabilityId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
