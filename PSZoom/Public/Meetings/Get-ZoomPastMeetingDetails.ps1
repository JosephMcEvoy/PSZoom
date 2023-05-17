<#

.SYNOPSIS
Retrieve the details of a past meeting.
.DESCRIPTION
Retrieve the details of a past meeting.
.PARAMETER MeetingUuid
The meeting UUID.

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
        [string]$MeetingUuid
     )

    process {
        $Uri = "https://api.$ZoomURI/v2/past_meetings/$MeetingUuid"
        
        $response = Invoke-ZoomRestMethod -Uri $Uri -Method GET
        
        Write-Output $response
    }
}
