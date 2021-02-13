<#

.SYNOPSIS
Retrieve the meeting invitation
.DESCRIPTION
Retrieve the meeting invitation
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeetingInvitation 123456789

#>

function Get-ZoomMeetingInvitation {
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
        $Uri = "https://api.zoom.us/v2/meetings/$MeetingId/invitation"
        
        $response = Invoke-ZoomRestMethod -Uri $Uri -Headers ([ref]$headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
        
        Write-Output $response
    }
}
