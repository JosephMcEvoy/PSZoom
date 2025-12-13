<#

.SYNOPSIS
Create a webinar for a user.

.DESCRIPTION
Use this API to schedule a webinar for a user (webinar host).

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:create, webinar:create:admin
Rate Limit Label: LIGHT

.PARAMETER UserId
The user ID or email address of the user. For user-level apps, pass the 'me' value instead of the user ID value.

.PARAMETER Topic
The webinar's topic.

.PARAMETER Type
The webinar type:
* 5 - Webinar.
* 6 - Recurring webinar with no fixed time.
* 9 - Recurring webinar with fixed time.

.PARAMETER StartTime
The webinar's start time (ISO 8601 format). This field is required for scheduled webinars and recurring webinars with fixed time.

.PARAMETER Duration
The webinar's scheduled duration (in minutes). This field is required for scheduled webinars.

.PARAMETER Timezone
The timezone to format the webinar's start time. For example, 'America/Los_Angeles'.

.PARAMETER Password
The password required to join the webinar. By default, a password can only have a maximum length of 10 characters and only contain alphanumeric characters and the @, -, _, and * characters.

.PARAMETER DefaultPasscode
Whether to generate a default password using the user's settings. The default value is $false.

.PARAMETER Agenda
The webinar's agenda. This value has a maximum length of 2,000 characters.

.PARAMETER TrackingFields
An array of tracking fields hashtables. Each hashtable should contain:
- field: The tracking field name (required)
- value: The tracking field value
- visible: Whether to show the tracking field in registration form

.PARAMETER Recurrence
A hashtable containing the recurrence settings. Required for recurring webinars. Should contain:
- type: The recurrence type (1=Daily, 2=Weekly, 3=Monthly)
- repeat_interval: The interval at which the webinar repeats
- weekly_days: Days of the week for weekly recurrence (e.g., '1,2,3')
- monthly_day: Day of the month for monthly recurrence
- monthly_week: Week of the month for monthly recurrence
- monthly_week_day: Day of week for monthly recurrence
- end_times: Number of times to recur
- end_date_time: End date/time for recurrence

.PARAMETER Settings
A hashtable containing the webinar settings. Can include various settings like host_video, panelists_video, audio, etc.

.PARAMETER TemplateId
The webinar template ID to use for creating the webinar.

.PARAMETER ScheduleFor
The email address or user ID of the user to schedule the webinar for. This field is only available to certain plans.

.PARAMETER IsSimulive
Whether the webinar is simulive. Default is $false.

.PARAMETER RecordFileId
The previously recorded file ID for simulive webinars.

.PARAMETER HostVideo
Start video when the host joins the webinar.

.PARAMETER PanelistsVideo
Start video when panelists join the webinar.

.PARAMETER ApprovalType
The approval type for the registration:
* 0 - Automatically approve.
* 1 - Manually approve.
* 2 - No registration required.

.PARAMETER RegistrationType
The registration type:
* 1 - Attendees register once and can attend any of the webinar occurrences.
* 2 - Attendees need to register for each occurrence to attend.
* 3 - Attendees register once and can choose one or more occurrences to attend.

.PARAMETER Audio
The audio type:
* both - Both telephony and VoIP.
* telephony - Telephony only.
* voip - VoIP only.

.PARAMETER AutoRecording
Automatic recording:
* local - Record to local device.
* cloud - Record to cloud.
* none - No automatic recording.

.PARAMETER AlternativeHosts
The alternative host's email addresses or IDs. Multiple values can be separated by semicolons.

.PARAMETER CloseRegistration
Whether to close registration after the event date. Default is $false.

.PARAMETER ContactName
The contact name for registration.

.PARAMETER ContactEmail
The contact email for registration.

.OUTPUTS
An object with the Zoom API response containing the created webinar information.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarCreate

.EXAMPLE
New-ZoomUserWebinar -UserId 'user@example.com' -Topic 'Product Launch' -Type 5 -StartTime '2024-06-15T14:00:00Z' -Duration 60

Creates a basic webinar scheduled for a specific date and time.

.EXAMPLE
$settings = @{
    host_video = $true
    panelists_video = $true
    approval_type = 0
    audio = 'both'
}
New-ZoomUserWebinar -UserId 'me' -Topic 'Weekly Training' -Type 5 -StartTime '2024-06-20T10:00:00Z' -Duration 120 -Settings $settings

Creates a webinar with custom settings.

.EXAMPLE
New-ZoomUserWebinar -UserId 'user@example.com' -Topic 'Q&A Session' -Type 5 -StartTime '2024-07-01T15:00:00Z' -Duration 90 -HostVideo $true -PanelistsVideo $true -AutoRecording 'cloud'

Creates a webinar using individual setting parameters.

#>

function New-ZoomUserWebinar {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_id', 'id', 'Email')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
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
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('default_passcode')]
        [bool]$DefaultPasscode,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(0, 2000)]
        [string]$Agenda,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('tracking_fields')]
        [System.Collections.IDictionary[]]$TrackingFields,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [System.Collections.IDictionary]$Recurrence,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [System.Collections.IDictionary]$Settings,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('template_id')]
        [string]$TemplateId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('schedule_for')]
        [string]$ScheduleFor,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('is_simulive')]
        [bool]$IsSimulive,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('record_file_id')]
        [string]$RecordFileId,

        # Individual settings parameters
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('host_video')]
        [bool]$HostVideo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('panelists_video')]
        [bool]$PanelistsVideo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('approval_type')]
        [ValidateSet(0, 1, 2)]
        [int]$ApprovalType,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('registration_type')]
        [ValidateSet(1, 2, 3)]
        [int]$RegistrationType,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('both', 'telephony', 'voip')]
        [string]$Audio,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('auto_recording')]
        [ValidateSet('local', 'cloud', 'none')]
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$UserId/webinars"

        # Build request body
        $RequestBody = @{}

        # Add required/common parameters
        if ($PSBoundParameters.ContainsKey('Topic')) {
            $RequestBody.Add('topic', $Topic)
        }

        if ($PSBoundParameters.ContainsKey('Type')) {
            $RequestBody.Add('type', $Type)
        }

        if ($PSBoundParameters.ContainsKey('StartTime')) {
            $RequestBody.Add('start_time', $StartTime)
        }

        if ($PSBoundParameters.ContainsKey('Duration')) {
            $RequestBody.Add('duration', $Duration)
        }

        if ($PSBoundParameters.ContainsKey('Timezone')) {
            $RequestBody.Add('timezone', $Timezone)
        }

        if ($PSBoundParameters.ContainsKey('Password')) {
            $RequestBody.Add('password', $Password)
        }

        if ($PSBoundParameters.ContainsKey('DefaultPasscode')) {
            $RequestBody.Add('default_passcode', $DefaultPasscode)
        }

        if ($PSBoundParameters.ContainsKey('Agenda')) {
            $RequestBody.Add('agenda', $Agenda)
        }

        if ($PSBoundParameters.ContainsKey('TrackingFields')) {
            $RequestBody.Add('tracking_fields', $TrackingFields)
        }

        if ($PSBoundParameters.ContainsKey('Recurrence')) {
            $RequestBody.Add('recurrence', $Recurrence)
        }

        if ($PSBoundParameters.ContainsKey('TemplateId')) {
            $RequestBody.Add('template_id', $TemplateId)
        }

        if ($PSBoundParameters.ContainsKey('ScheduleFor')) {
            $RequestBody.Add('schedule_for', $ScheduleFor)
        }

        if ($PSBoundParameters.ContainsKey('IsSimulive')) {
            $RequestBody.Add('is_simulive', $IsSimulive)
        }

        if ($PSBoundParameters.ContainsKey('RecordFileId')) {
            $RequestBody.Add('record_file_id', $RecordFileId)
        }

        # Handle settings - either use provided Settings hashtable or build from individual parameters
        if ($PSBoundParameters.ContainsKey('Settings')) {
            $RequestBody.Add('settings', $Settings)
        }
        else {
            # Build settings from individual parameters if any are provided
            $settingsHash = @{}

            if ($PSBoundParameters.ContainsKey('HostVideo')) {
                $settingsHash.Add('host_video', $HostVideo)
            }

            if ($PSBoundParameters.ContainsKey('PanelistsVideo')) {
                $settingsHash.Add('panelists_video', $PanelistsVideo)
            }

            if ($PSBoundParameters.ContainsKey('ApprovalType')) {
                $settingsHash.Add('approval_type', $ApprovalType)
            }

            if ($PSBoundParameters.ContainsKey('RegistrationType')) {
                $settingsHash.Add('registration_type', $RegistrationType)
            }

            if ($PSBoundParameters.ContainsKey('Audio')) {
                $settingsHash.Add('audio', $Audio)
            }

            if ($PSBoundParameters.ContainsKey('AutoRecording')) {
                $settingsHash.Add('auto_recording', $AutoRecording)
            }

            if ($PSBoundParameters.ContainsKey('AlternativeHosts')) {
                $settingsHash.Add('alternative_hosts', $AlternativeHosts)
            }

            if ($PSBoundParameters.ContainsKey('CloseRegistration')) {
                $settingsHash.Add('close_registration', $CloseRegistration)
            }

            if ($PSBoundParameters.ContainsKey('ContactName')) {
                $settingsHash.Add('contact_name', $ContactName)
            }

            if ($PSBoundParameters.ContainsKey('ContactEmail')) {
                $settingsHash.Add('contact_email', $ContactEmail)
            }

            if ($settingsHash.Count -gt 0) {
                $RequestBody.Add('settings', $settingsHash)
            }
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("User $UserId", "Create webinar '$Topic'")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method POST

            Write-Output $response
        }
    }
}
