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
Update-ZoomMeetingLiveStream  123456789

#>

function Update-ZoomMeetingLiveStream {
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

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [ValidateLength(0, 1024)]
        [Alias('stream_url')]
        [string]$StreamUrl,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [ValidateLength(0, 512)]
        [Alias('stream_key')]
        [string]$StreamKey,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 1024)]
        [Alias('page_url')]
        [string]$PageUrl
     )

    process {
        $uri = "https://api.$ZoomURI/v2/meetings/$MeetingId/livestream"
        $requestBody = @{
            'stream_url' = $StreamUrl
            'stream_key' = $StreamKey
        }

        if ($PSBoundParameters.ContainsKey('PageUrl')) {
            $requestBody.Add('page_url', $PageUrl)
        }

        $requestBody = ConvertTo-Json $requestBody
                
        $response = Invoke-ZoomRestMethod -Uri $uri -Body $requestBody -Method PATCH
        
        Write-Output $response
    }
}
