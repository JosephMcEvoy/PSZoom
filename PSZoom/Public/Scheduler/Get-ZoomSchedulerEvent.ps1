<#

.SYNOPSIS
Get a Scheduler event.

.DESCRIPTION
Retrieve details of a specific Scheduler event by ID.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:event:admin

.PARAMETER EventId
The Scheduler event ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getSchedulerEvent

.EXAMPLE
Get-ZoomSchedulerEvent -EventId "abc123"

Retrieve details of a specific Scheduler event.

#>

function Get-ZoomSchedulerEvent {
    [CmdletBinding()]
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

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
