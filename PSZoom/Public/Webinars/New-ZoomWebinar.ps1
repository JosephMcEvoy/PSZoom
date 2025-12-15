<#

.SYNOPSIS
Create a webinar for a user.

.DESCRIPTION
Create a webinar for a user. The expiration time for the start_url object is two hours.

.PARAMETER UserId
The user ID or email address of the user.

.PARAMETER Topic
Webinar topic.

.PARAMETER Type
Webinar type. 5 - Webinar, 6 - Recurring webinar with no fixed time, 9 - Recurring webinar with fixed time.

.PARAMETER StartTime
Webinar start time in GMT/UTC format.

.PARAMETER Duration
Webinar duration in minutes.

.PARAMETER Timezone
Time zone to format start_time.

.PARAMETER Password
Webinar password. Max 10 characters.

.PARAMETER Agenda
Webinar description.

.PARAMETER TrackingFields
Tracking fields array.

.PARAMETER Settings
Webinar settings object.

.PARAMETER HostVideo
Start video when the host joins the webinar.

.PARAMETER PanelistsVideo
Start video when panelists join the webinar.

.PARAMETER ApprovalType
Approval type. 0 - Automatically approve, 1 - Manually approve, 2 - No registration required.

.PARAMETER RegistrationType
Registration type. 1 - Attendees register once, 2 - Register for each occurrence, 3 - Register once and choose occurrences.

.PARAMETER Audio
Audio options. both, telephony, voip.

.PARAMETER AutoRecording
Automatic recording. local, cloud, none.

.PARAMETER AlternativeHosts
Alternative host's emails or IDs.

.PARAMETER CloseRegistration
Close registration after event date.

.PARAMETER ContactName
Contact name for registration.

.PARAMETER ContactEmail
Contact email for registration.

.EXAMPLE
New-ZoomWebinar -UserId 'user@company.com' -Topic 'My Webinar'

.EXAMPLE
New-ZoomWebinar -UserId 'user@company.com' -Topic 'Scheduled Webinar' -StartTime '2024-01-15T10:00:00Z' -Duration 60

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarCreate

#>

function New-ZoomWebinar {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('user_id', 'id', 'host_id')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Topic,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet(5, 6, 9)]
        [int]$Type = 5,

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
        [Alias('tracking_fields')]
        [hashtable[]]$TrackingFields,

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
        [ValidateSet(1, 2, 3)]
        [Alias('registration_type')]
        [int]$RegistrationType,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('both', 'telephony', 'voip')]
        [string]$Audio,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('local', 'cloud', 'none')]
        [Alias('auto_recording')]
        [string]$AutoRecording,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('alternative_hosts')]
        [string]$AlternativeHosts,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('close_registration')]
        [bool]$CloseRegistration,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('contact_name')]
        [string]$ContactName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('contact_email')]
        [string]$ContactEmail
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/users/$UserId/webinars"

        $requestBody = @{
            'topic' = $Topic
            'type'  = $Type
        }

        # Optional parameters
        $optionalParams = @{
            'start_time'      = 'StartTime'
            'duration'        = 'Duration'
            'timezone'        = 'Timezone'
            'password'        = 'Password'
            'agenda'          = 'Agenda'
            'tracking_fields' = 'TrackingFields'
        }

        foreach ($key in $optionalParams.Keys) {
            $paramName = $optionalParams[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        # Settings
        $settings = @{}
        $settingsParams = @{
            'host_video'         = 'HostVideo'
            'panelists_video'    = 'PanelistsVideo'
            'approval_type'      = 'ApprovalType'
            'registration_type'  = 'RegistrationType'
            'audio'              = 'Audio'
            'auto_recording'     = 'AutoRecording'
            'alternative_hosts'  = 'AlternativeHosts'
            'close_registration' = 'CloseRegistration'
            'contact_name'       = 'ContactName'
            'contact_email'      = 'ContactEmail'
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

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
