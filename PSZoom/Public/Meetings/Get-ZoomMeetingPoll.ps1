<#

.SYNOPSIS
Retrieve a meeting's poll.
.DESCRIPTION
Retrieve a meeting's poll.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER PollId
The poll ID.

.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeetingPoll 123456789 987654321

#>

function Get-ZoomMeetingPoll {
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/polls/$PollId"
    
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}
