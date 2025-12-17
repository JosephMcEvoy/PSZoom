<#

.SYNOPSIS
Update a Scheduler event.

.DESCRIPTION
Update an existing Scheduler event with new details.

Scopes: scheduler:write:admin
Granular Scopes: scheduler:write:event:admin

.PARAMETER EventId
The Scheduler event ID.

.PARAMETER Title
The event title.

.PARAMETER Description
The event description.

.PARAMETER StartTime
The event start time in ISO 8601 format (e.g., "2024-01-15T10:00:00Z").

.PARAMETER Duration
The event duration in minutes.

.PARAMETER Status
The event status (e.g., 'confirmed', 'cancelled').

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateSchedulerEvent

.EXAMPLE
Update-ZoomSchedulerEvent -EventId "abc123" -Title "Updated Meeting" -StartTime "2024-01-15T10:00:00Z"

Update a Scheduler event's title and start time.

#>

function Update-ZoomSchedulerEvent {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('event_id', 'id')]
        [string]$EventId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_title')]
        [string]$Title,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_description')]
        [string]$Description,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('start_time')]
        [string]$StartTime,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_duration')]
        [int]$Duration,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('event_status')]
        [string]$Status
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/events/$EventId"

        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('Title')) {
            $requestBody.Add('title', $Title)
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $requestBody.Add('description', $Description)
        }

        if ($PSBoundParameters.ContainsKey('StartTime')) {
            $requestBody.Add('start_time', $StartTime)
        }

        if ($PSBoundParameters.ContainsKey('Duration')) {
            $requestBody.Add('duration', $Duration)
        }

        if ($PSBoundParameters.ContainsKey('Status')) {
            $requestBody.Add('status', $Status)
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method PATCH

        Write-Output $response
    }
}
