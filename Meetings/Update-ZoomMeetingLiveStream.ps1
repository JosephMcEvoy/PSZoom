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
.EXAMPLE
Update-ZoomMeetingLiveStream  123456789


#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Update-ZoomMeetingLiveStream {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            Position = 0
        )]
        [string]$MeetingId,
        
        [ValidateLength(0, 1024)]
        [string]$StreamUrl,
        
        [ValidateLength(0, 512)]
        [string]$StreamKey,
        
        [ValidateLength(0, 1024)]
        [string]$PageUrl,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Uri = "https://api.zoom.us/v2/meetings/$MeetingId/invitation"
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
            $Response = Invoke-RestMethod -Uri $Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}