<#

.SYNOPSIS
Retrieve participants from a past meeting from the metrics API.
.DESCRIPTION
Retrieve participants from a past meeting, includes location and other data. Note: Please double encode your UUID when using this API. The default meeting type is past because I cannot see a reason to  use either live or pastone...
.PARAMETER MeetingUuid
The meeting UUID or meeting ID. Use the UUID if possible because it is simpler to work with reoccuring meetings while doing so.
.PARAMETER Type
The meeting type (live, past or pastone).
.PARAMETER page_size
1-300. I default to 300 because I don't want to deal with paging at this level since this work will probably not be worth anything once we sign the HIPPA BAA with Zoom
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
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
        [string]$Type = 'past',

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/metrics/meetings/$MeetingUuid/participants"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $query.Add('page_size', $PageSize)
        $query.Add('type', $type)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()
        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Body $RequestBody -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
        
        Write-Output $response
    }
}