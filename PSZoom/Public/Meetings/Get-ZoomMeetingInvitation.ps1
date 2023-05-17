<#

.SYNOPSIS
Retrieve the meeting invitation
.DESCRIPTION
Retrieve the meeting invitation
.PARAMETER MeetingId
The meeting ID.

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
        [string]$MeetingId
     )

    process {
        $Uri = "https://api.$ZoomURI/v2/meetings/$MeetingId/invitation"
        
        $response = Invoke-ZoomRestMethod -Uri $Uri -Method GET
        
        Write-Output $response
    }
}
