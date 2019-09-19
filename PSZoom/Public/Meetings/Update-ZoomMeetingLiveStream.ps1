<#

.SYNOPSIS
Update a meeting’s live stream.
.DESCRIPTION
Update a meeting’s live stream.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
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
        [string]$PageUrl,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Uri = "https://api.zoom.us/v2/meetings/$MeetingId/livestream"
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('StreamUrl')) {
            $RequestBody.Add('stream_url', $StreamUrl)
        }

        if ($PSBoundParameters.ContainsKey('StreamKey')) {
            $RequestBody.Add('stream_key', $StreamKey)
        }

        if ($PSBoundParameters.ContainsKey('PageUrl')) {
            $RequestBody.Add('page_url', $PageUrl)
        }
                
        try {
            $response = Invoke-RestMethod -Uri $Uri -Headers $headers -Body $RequestBody -Method PATCH
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        
        Write-Output $response
    }
}
