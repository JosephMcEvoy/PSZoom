<#

.SYNOPSIS
Update a meeting’s live stream.
.DESCRIPTION
Update a meeting’s live stream.
.PARAMETER MeetingId
The meeting ID.

.OUTPUTS
.LINK
.EXAMPLE
Update-ZoomMeetingLiveStream 123456789

#>

function Update-ZoomMeetingLiveStreamStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 1024)]
        [Alias('stream_url')]
        [string]$StreamUrl,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 512)]
        [Alias('stream_key')]
        [string]$StreamKey,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 1024)]
        [Alias('page_url')]
        [string]$PageUrl
     )

    process {
        $Uri = "https://api.$ZoomURI/v2/meetings/$MeetingId/livestream/status"
        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('StreamUrl')) {
            $requestBody.Add('stream_url', $StreamUrl)
        }

        if ($PSBoundParameters.ContainsKey('StreamKey')) {
            $requestBody.Add('stream_key', $StreamKey)
        }

        if ($PSBoundParameters.ContainsKey('PageUrl')) {
            $requestBody.Add('page_url', $PageUrl)
        }
        
        $requestBody = $requestBody | ConvertTo-Json

        $response = Invoke-ZoomRestMethod -Uri $uri -Body $requestBody -Method PATCH
        
        Write-Output $response
    }
}