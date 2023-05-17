<#

.SYNOPSIS
Retrieve participants from a past meeting.
.DESCRIPTION
Retrieve participants from a past meeting. Note: Please double encode your UUID when using this API.
.PARAMETER MeetingUuid
The meeting UUID.

.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomPastMeetingParticipants 123456789

#>

function Get-ZoomPastMeetingParticipants {
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
        [int]$PageSize = 30,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/past_meetings/$MeetingUuid/participants"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()
        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}