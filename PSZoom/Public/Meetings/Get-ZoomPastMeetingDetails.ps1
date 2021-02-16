<#

.SYNOPSIS
Retrieve the details of a past meeting.
.DESCRIPTION
Retrieve the details of a past meeting.
.PARAMETER MeetingUuid
The meeting UUID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomPastMeetingDetails 123456789


#>

function Get-ZoomPastMeetingDetails {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('uuid')]
        [string]$MeetingUuid,

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
        $Uri = "https://api.zoom.us/v2/past_meetings/$MeetingUuid"
        
        $response = Invoke-ZoomRestMethod -Uri $Uri -Headers ([ref]$headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
        
        Write-Output $response
    }
}
