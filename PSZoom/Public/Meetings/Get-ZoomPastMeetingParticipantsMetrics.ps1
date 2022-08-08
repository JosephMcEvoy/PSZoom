<#

.SYNOPSIS
Retrieve participants from a past meeting from the metrics API.

.DESCRIPTION
Retrieve participants from a past meeting, includes location and other data. Note: Please double encode your UUID when using this API. The default meeting type is past because I cannot see a reason to  use either live or pastone...

.PARAMETER MeetingUuid
The meeting UUID or meeting ID. Use the UUID if possible because it is simpler to work with reoccuring meetings while doing so.

.PARAMETER Type
The meeting type (live, past or pastone).

.PARAMETER PageSize
1-300. Default = 300

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/dashboards/dashboardmeetingparticipants

.EXAMPLE
Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 123456789

#>

function Get-ZoomPastMeetingParticipantsMetrics {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'meeting_uuid', 'uuid')]
        [string]$MeetingUuid,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 300,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [ValidateSet('past','pastOne','live')]
        [string]$Type = 'past'
     )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/metrics/meetings/$MeetingUuid/participants"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $query.Add('page_size', $PageSize)
        $query.Add('type', $Type)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()
        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}
