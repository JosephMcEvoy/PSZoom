<#

.SYNOPSIS
Retrieve the details of a meeting.

.DESCRIPTION
Retrieve the details of a meeting.

.PARAMETER MeetingId
The meeting ID.

.PARAMETER OcurrenceId
The Occurrence ID.

.OUTPUTS

.LINK

.EXAMPLE
Get-ZoomMeeting 123456789

.EXAMPLE
Get the host of a Zoom meeting.
Get-ZoomMeeting 123456789 | Select-Object host_id | Get-ZoomUser

#>

function Get-ZoomMeeting {
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
            Position=1
        )]
        [Alias('ocurrence_id')]
        [string]$OccurrenceId
     )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query.Add('occurrence_id', $OccurrenceId)
            $Request.Query = $query.toString()
        }        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}
