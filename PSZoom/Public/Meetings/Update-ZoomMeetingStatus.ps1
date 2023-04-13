<#

.SYNOPSIS
End a meeting by updating its status.
.DESCRIPTION
End a meeting by updating its status.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER Action
The update action. Available actions: end.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/meetings/meetingstatus
.EXAMPLE
Ends a meeting.
Update-MeetingStatus -MeetingId '123456789'

#>

function Update-ZoomMeetingStatus {
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
            ValueFromPipelineByPropertyName = $True, 
            Position = 1
        )]
        [ValidateSet('end')]
        [string]$Action = 'end'
    )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/meetings/$MeetingId/status"

        $requestBody = @{
            'action' = $Action
        }

        $requestBody = $requestBody | ConvertTo-Json

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PUT
        
        Write-Output $response
    }
}