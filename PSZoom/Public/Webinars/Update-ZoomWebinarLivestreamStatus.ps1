<#

.SYNOPSIS
Update a webinar livestream's status.

.DESCRIPTION
Update a webinar livestream's status. Use this API to start or stop a webinar's livestream.

Prerequisites:
* The host must be a licensed user with a Webinar plan.
* The Webinar Livestream feature must be enabled.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:update:livestream_status, webinar:update:livestream_status:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER Action
The action to perform on the livestream:
* start - Start the webinar's livestream.
* stop - Stop the webinar's livestream.

.PARAMETER Settings
A hashtable containing livestream settings. Can include:
- stream_url: The livestream URL
- stream_key: The livestream key
- page_url: The livestream page URL

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateWebinarLiveStreamStatus

.EXAMPLE
Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start'

Starts the livestream for the specified webinar.

.EXAMPLE
Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'stop'

Stops the livestream for the specified webinar.

.EXAMPLE
$settings = @{
    stream_url = 'rtmp://stream.example.com/live'
    stream_key = 'abc123xyz'
    page_url = 'https://example.com/watch/live'
}
Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Settings $settings

Starts the livestream with custom settings.

#>

function Update-ZoomWebinarLivestreamStatus {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'Id')]
        [int64]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('start', 'stop')]
        [string]$Action,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [System.Collections.IDictionary]$Settings
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/livestream/status"

        # Build request body
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('Action')) {
            $RequestBody.Add('action', $Action)
        }

        if ($PSBoundParameters.ContainsKey('Settings')) {
            $RequestBody.Add('settings', $Settings)
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", "Update livestream status to '$Action'")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method PATCH

            Write-Output $response
        }
    }
}
