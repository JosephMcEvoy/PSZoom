<#

.SYNOPSIS
Delete a meeting's poll.
.DESCRIPTION
Delete a meeting's poll.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER PollId
The poll ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Remove-ZoomMeetingPoll 123456789 987654321

#>

function Remove-ZoomMeetingPoll {
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
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('poll_id')]
        [string]$PollId,

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
        $request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/polls/$PollId"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Body $RequestBody -Method DELETE -ApiKey $ApiKey -ApiSecret $ApiSecret
        
        Write-Output $response
    }
}