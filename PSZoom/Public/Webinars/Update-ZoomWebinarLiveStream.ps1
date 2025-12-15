<#

.SYNOPSIS
Update a webinar's live stream settings.

.DESCRIPTION
Update a webinar's live stream settings.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER StreamUrl
Streaming URL.

.PARAMETER StreamKey
Streaming key.

.PARAMETER PageUrl
The live streaming page URL.

.EXAMPLE
Update-ZoomWebinarLiveStream -WebinarId 123456789 -StreamUrl 'rtmp://live.example.com/app' -StreamKey 'mykey123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarLiveStreamUpdate

#>

function Update-ZoomWebinarLiveStream {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('stream_url')]
        [string]$StreamUrl,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('stream_key')]
        [string]$StreamKey,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_url')]
        [string]$PageUrl
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/livestream"

        $requestBody = @{
            'stream_url' = $StreamUrl
            'stream_key' = $StreamKey
        }

        if ($PSBoundParameters.ContainsKey('PageUrl')) {
            $requestBody['page_url'] = $PageUrl
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Patch

        Write-Output $response
    }
}
