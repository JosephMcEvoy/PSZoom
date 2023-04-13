<#

.SYNOPSIS
List polls  of a meeting.
.DESCRIPTION
List polls  of a meeting. 
Host user must be in a Pro plan.
Meeting must be a scheduled meeting. Instant meetings do not have polling features enabled.
.PARAMETER MeetingId
The meeting ID.

.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeetingsPolls 123456789

#>

function Get-ZoomMeetingPolls {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId
     )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/meetings/$MeetingId/polls"
   
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}