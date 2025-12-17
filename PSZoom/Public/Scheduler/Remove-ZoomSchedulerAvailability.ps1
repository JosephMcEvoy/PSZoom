<#

.SYNOPSIS
Delete a Scheduler availability.

.DESCRIPTION
Delete a specific Scheduler availability configuration by ID.

Scopes: scheduler:write:admin
Granular Scopes: scheduler:write:availability:admin

.PARAMETER AvailabilityId
The Scheduler availability ID.

.OUTPUTS
System.Boolean

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deleteSchedulerAvailability

.EXAMPLE
Remove-ZoomSchedulerAvailability -AvailabilityId "abc123"

Delete a Scheduler availability configuration.

.EXAMPLE
Remove-ZoomSchedulerAvailability -AvailabilityId "abc123" -Confirm:$false

Delete a Scheduler availability configuration without confirmation prompt.

#>

function Remove-ZoomSchedulerAvailability {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
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

        if ($PSCmdlet.ShouldProcess($AvailabilityId, "Delete Scheduler availability")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            Write-Output $true
        }
    }
}
