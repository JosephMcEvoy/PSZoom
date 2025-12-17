<#

.SYNOPSIS
Delete a Scheduler event.

.DESCRIPTION
Delete a specific Scheduler event by ID.

Scopes: scheduler:write:admin
Granular Scopes: scheduler:write:event:admin

.PARAMETER EventId
The Scheduler event ID.

.OUTPUTS
System.Boolean

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deleteSchedulerEvent

.EXAMPLE
Remove-ZoomSchedulerEvent -EventId "abc123"

Delete a Scheduler event.

.EXAMPLE
Remove-ZoomSchedulerEvent -EventId "abc123" -Confirm:$false

Delete a Scheduler event without confirmation prompt.

#>

function Remove-ZoomSchedulerEvent {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('event_id', 'id')]
        [string]$EventId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/events/$EventId"

        if ($PSCmdlet.ShouldProcess($EventId, "Delete Scheduler event")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            Write-Output $true
        }
    }
}
