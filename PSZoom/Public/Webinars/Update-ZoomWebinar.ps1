<#

.SYNOPSIS
Update a webinar's settings.

.DESCRIPTION
Update a webinar's settings. Use this API to update a webinar's settings.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER OccurrenceId
Webinar occurrence ID.

.PARAMETER Topic
Webinar topic.

.PARAMETER Type
Webinar type.

.PARAMETER StartTime
Webinar start time.

.PARAMETER Duration
Webinar duration in minutes.

.PARAMETER Timezone
Time zone to format start_time.

.PARAMETER Password
Webinar password.

.PARAMETER Agenda
Webinar description.

.PARAMETER Settings
Webinar settings object.

.EXAMPLE
Update-ZoomWebinar -WebinarId 123456789 -Topic 'Updated Webinar Topic'

.EXAMPLE
Update-ZoomWebinar -WebinarId 123456789 -StartTime '2024-01-20T14:00:00Z' -Duration 90

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarUpdate

#>

function Update-ZoomWebinar {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('occurrence_id')]
        [string]$OccurrenceId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Topic,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet(5, 6, 9)]
        [int]$Type,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('start_time')]
        [string]$StartTime,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [int]$Duration,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Timezone,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidatePattern("[A-Za-z0-9@\-_\*]{1,10}")]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Agenda,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('host_video')]
        [bool]$HostVideo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('panelists_video')]
        [bool]$PanelistsVideo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet(0, 1, 2)]
        [Alias('approval_type')]
        [int]$ApprovalType,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('both', 'telephony', 'voip')]
        [string]$Audio,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('local', 'cloud', 'none')]
        [Alias('auto_recording')]
        [string]$AutoRecording,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('alternative_hosts')]
        [string]$AlternativeHosts
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId"

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('occurrence_id', $OccurrenceId)
            $Request.Query = $query.ToString()
        }

        $requestBody = @{}

        # Main parameters
        $mainParams = @{
            'topic'      = 'Topic'
            'type'       = 'Type'
            'start_time' = 'StartTime'
            'duration'   = 'Duration'
            'timezone'   = 'Timezone'
            'password'   = 'Password'
            'agenda'     = 'Agenda'
        }

        foreach ($key in $mainParams.Keys) {
            $paramName = $mainParams[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        # Settings
        $settings = @{}
        $settingsParams = @{
            'host_video'        = 'HostVideo'
            'panelists_video'   = 'PanelistsVideo'
            'approval_type'     = 'ApprovalType'
            'audio'             = 'Audio'
            'auto_recording'    = 'AutoRecording'
            'alternative_hosts' = 'AlternativeHosts'
        }

        foreach ($key in $settingsParams.Keys) {
            $paramName = $settingsParams[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $settings[$key] = (Get-Variable $paramName).Value
            }
        }

        if ($settings.Count -gt 0) {
            $requestBody['settings'] = $settings
        }

        if ($requestBody.Count -gt 0) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method Patch
            Write-Output $response
        }
    }
}
