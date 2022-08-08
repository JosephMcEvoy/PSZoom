<#

.SYNOPSIS
List of ended meeting instances
.DESCRIPTION
List of ended meeting instances
.PARAMETER MeetingId
The meeting ID.

.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomEndedMeetingInstances 123456789

#>

function Get-ZoomEndedMeetingInstances {
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/past_meetings/$MeetingId/instances"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}