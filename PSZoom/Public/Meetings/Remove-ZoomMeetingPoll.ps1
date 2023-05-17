<#

.SYNOPSIS
Delete a meeting's poll.
.DESCRIPTION
Delete a meeting's poll.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER PollId
The poll ID.

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
        [string]$PollId
     )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/meetings/$MeetingId/polls/$PollId"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method DELETE
        
        Write-Output $response
    }
}