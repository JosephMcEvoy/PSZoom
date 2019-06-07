function New-ZoomMeeting {
    <#
    .SYNOPSIS
    Create a meeting for a user.

    .DESCRIPTION
    Create a meeting for a user. The expiration time for the start_url object is two hours. For API users, the expiration time is 90 days.

    .PARAMETER ApiKey
    The API key.
    
    .PARAMETER ApiSecret
    The API secret.

    .PARAMETER ScheduleFor
    Email or userId if you want to schedule meeting for another user.

    .PARAMETER Topic
    Meeting topic.

    .PARAMETER Type
    Meeting type. 1 - Instant meeting, 2 - Scheduled meeting, 3 - Recurring meeting with no fixed time, 8 - Recurring meeting with fixed time.


    .PARAMETER StartTime
    Meeting start time. When using a format like \"yyyy-MM-dd'T'HH:mm:ss'Z'\", always use GMT time. When using a format like \"yyyy-MM-dd'T'HH:mm:ss\", 
    you should use local time and specify the time zone. This is only used for scheduled meetings and recurring meetings with a fixed time.

    .PARAMETER Duration
    Meeting duration (minutes). Used for scheduled meetings only.
    
    .PARAMETER Timezone
    Time zone to format start_time. For example, \"America/Los_Angeles\". For scheduled meetings only. 
    Please reference our [time zone](https://marketplace.zoom.us/docs/api-reference/other-references/abbreviation-lists#timezones) list for supported time zones and their formats.
    
    .PARAMETER Password
    Password to join the meeting. Password may only contain the following characters: [a-z A-Z 0-9 @ - _ *]. Max of 10 characters.

    .PARAMETER Agenda
    Meeting description.

    .PARAMETER TrackingFields
    Tracking fields. An array of objects where each object contains two keys (field, value). Example: @(@{field = value, value = value}, @{field = value, value = value})

    .PARAMETER Recurrence
    Recurrence object. Pass an entire recurrence object directly. Cannot be used with other recurrence parameters.

    .PARAMETER RecurrenceType
    Recurrence meeting types: 
    1 - Daily
    2 - Weekly
    3 - Monthly

    .PARAMETER RecurrenceRepeatInterval
    At which interval should the meeting repeat? For a daily meeting there's a maximum of 90 days. 
    For a weekly meeting there is a maximum of 12 weeks. 
    For a monthly meeting there is a maximum of 3 months.

    .PARAMETER RecurrenceWeeklyDays
    Days of the week the meeting should repeat. Note: Multiple values should be separated by a comma. 
    1 - Sunday
    2 - Monday
    3 - Tuesday
    4 - Wednesday
    5 - Thursday
    6 - Friday
    7 - Saturday
    
    .PARAMETER RecurrenceMonthlyDay
    Day in the month the meeting is to be scheduled. The value is from 1 to 31.

    .PARAMETER RecurrenceMonthlyWeek
    The week a meeting will recur each month.
    -1 - Last wek
    1 - First week
    2 - Second week
    3 - Third week
    4 - Fourth week

    .PARAMETER RecurrenceMonthlyWeekDay
    The weekday a meeting should recur each month.
    1 - Sunday
    2 - Monday
    3 - Tuesday
    4 - Wednesday
    5 - Thursday
    6 - Friday
    7 - Saturday

    .PARAMETER RecurrenceEndTimes
    Select how many timse the meeting will recur before it is canceled. (Cannot be used with "RecurrenceEndDateTime".)

    .PARAMETER RecurrenceEndDateTime
    Select a date the meeting will recur before it is canceled. Should be in UTC time, such as 2017-11-25T12:00:00Z. (Cannot be used with "RecurrenceEndTimes".)

    .PARAMETER Settings
    Meeting settings object. Pass an entire settings object directly.


    .PARAMETER HostVideo
    Start video when the host joins the meeting.

    .PARAMETER ParticipantVideo
    Start video when participants join the meeting.

    .PARAMETER CNMeeting
    Host meeting in China.

    .PARAMETER INMeeting
    Host meeting in India.

    .PARAMETER JoinBeforeHost
    Allow participants to join the meeting before the host starts the meeting. Only used for scheduled or recurring meetings.

    .PARAMETER MuteUponEntry
    Mute participants upon entry.

    .PARAMETER Watermark
    Add watermark when viewing a shared screen.

    .PARAMETER UsePMI
    Use a personal meeting ID. Only used for scheduled meetings and recurring meetings with no fixed time.

    .PARAMETER ApprovalType
    0 - Automatically approve
    1 - Manually approve
    2 - No registration required

    .PARAMETER RegistrationType
    Registration type. Used for recurring meeting with fixed time only. 
    1 Attendees register once and can attend any of the occurrences.
    2 Attendees need to register for each occurrence to attend.
    3 Attendees register once and can choose one or more occurrences to attend.

    .PARAMETER Audio
    Determine how participants can join the audio portion of the meeting.<br>`both` - Both Telephony and VoIP.<br>`telephony` - Telephony only.<br>`voip` - VoIP only.

    .PARAMETER AutoRecording
    Automatic recording:
    local - Record on local.
    cloud -  Record on cloud.
    none - Disabled.

    .PARAMETER EnforceLogin
    Only signed in users can join this meeting.

    .PARAMETER EnforceLoginDomains
    Only signed in users with specified domains can join meetings.

    .PARAMETER AlternativeHosts
    Alternative host's emails or IDs: multiple values separated by a comma.

    .PARAMETER CloseRegistration
    Close registration after event date

    .PARAMETER WaitingRoom
    Enable waiting room

    .PARAMETER GlobalDialInCountries
    List of global dial-in countries

    .PARAMETER ContactName
    Contact name for registration

    .PARAMETER ContacEmail
    Contact email for registration
    #>
                      

  [CmdletBinding(DefaultParameterSetName="All")]
  param (
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey,

    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiSecret,

    [ValidateNotNullOrEmpty()]
    [string]$ScheduleFor,

    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$Topic,

    [ValidateSet(1,2,3,8)]
    [ValidateNotNullOrEmpty()]
    [int]$Type = 2,

    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [string]$StartTime,

    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [int]$Duration,

    [string]$Timezone,

    [ValidatePattern("[A-Za-z0-9@-_\*]*")]
    [string]$Password,

    [string]$Agenda,

    [hashtable[]]$TrackingFields,

    [hashtable]$Recurrence,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,3)]
    [int]$RecurrenceType,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,90)]
    [int]$RecurrenceRepeatInterval,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [ValidateRange(1,7)]
    [int[]]$RecurrenceWeeklyDays,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [ValidateRange(1,31)]
    [int]$RecurrenceMonthlyDay,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateSet(-1,1,2,3,4)]
    [int]$RecurrenceMonthlyWeek,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,7)]
    [int]$RecurrenceMonthlyWeekDay,

    [Parameter(ParameterSetName='RecurrenceByDay')]
    [Parameter(ParameterSetName='RecurrenceByWeek')]
    [Parameter(ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,50)]
    [int]$RecurrenceEndTimes,
    
    [Parameter(ParameterSetName='RecurrenceByDay')]
    [Parameter(ParameterSetName='RecurrenceByWeek')]
    [Parameter(ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(ParameterSetName='RecurrenceByMonthWeek')]
    [ValidatePattern("^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z)?$")] 
    #Example: 2016-04-06T10:10:09Z. Regex taken from https://www.regextester.com/94925
    [string]$RecurrenceEndDateTime,

    [hashtable]$Settings,

    [bool]$HostVideo,

    [bool]$CNMeeting = $false,

    [bool]$INMeeting = $false,

    [bool]$JoinBeforeHost = $false,

    [bool]$MuteUponEntry = $false,

    [bool]$Watermark = $false,

    [bool]$UsePMI = $false,

    [ValidateRange(0,2)]
    [int]$ApprovalType = 2,

    [ValidateRange(0,3)]
    [int]$RegistrationType = 1,

    [ValidateSet('both', 'telephony', 'voip')]
    [string]$Audio,

    [ValidateSet('local','cloud','none')]
    [string]$AutoRecording = $false,

    [bool]$EnforceLogin,

    [bool]$EnforceLoginDomains,

    [string]$AlternativeHosts,

    [bool]$CloseRegistration = $false,

    [bool]$WaitingRoom = $false,

    [string[]]$GlobalDialInCountries,

    [string]$ContactName,

    [string]$ContactEmail
  )
  
  begin {
  }
  
  process {
    # Additional StartTime and Duration parameter validation
    if (($Type -eq 1) -and ($StartTime -or $Duration)){
        Throw [System.Management.Automation.ValidationMetadataException] 'Parameter StartTime cannot be used with Type 1 (Instant Meeting).'
    }

    #The following parameters are added by default as they are requierd by all parameter sets.
    $RequestBody = @{
        'api_key'      = $ApiKey
        'api_secret'   = $ApiSecret
        'schedule_for' = $ScheduleFor
        'topic'        = $Topic
        'type'         = $Type
    }

    #These are optional meeting parameters.
    $OptionalParameters = @{
        'timezone'        = $Timezone
        'password'        = $Password
        'agenda'          = $Agenda
        'tracking_fields' = $TrackingFields
    }

    $OptionalParameters.Keys | ForEach-Object {
        if ($null -ne $OptionalParameters.$_) {
            $RequestBody.Add($_, $OptionalParameters.$_)
        }
    }
   
    #The following parameters are mandatory for 5 parameter sets. If one of these parameter sets is being used, the corresponding keys are added to the RequestBody
    if (('ScheduledMeeting', 'RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {
        $RequestBody.Add('start_time', $StartTime)
        $RequestBody.Add('duration', $Duration)
    }


    if (('RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {
        #Recurrence parameter validation
        if (($Type -eq 1 -or $Type -eq 2) -and ($Recurrence -or $RecurrenceType)){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter Recurrence and RecurrenceType requres Type to be set to 3 (Recurring meeting with no fixed time) or 8 (Recurring meeting with fixed time).'
        }
    
        if ($RecurrenceType -ne 2 -and $RecurrenceWeeklyDays) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceWeeklyDays requires RecurrenceType to be set to 2 (Weekly).'
        }
    
        if ($RecurrenceType -eq 2 -and $RecurrenceRepeatInterval -le 12){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceRepeatInterval only accepts values between 1 and 12 when RecurrenceType is set to 2 (Weekly).'
        } elseif ($RecurrenceType -eq 3 -and $RecurrenceRepeatInterval -le 3){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceRepeatInterval only accepts values between 1 and 3 when RecurrenceType is set to 3 (Monthly).'
        }
    
        if ($RecurrenceType -ne 3 -and $RecurrenceMonthlyDay) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceMonthlyDay requires RecurrenceType to be set to 3 (Monthly).'
        }
    
        if ($RecurrenceType -ne 3 -and $RecurrenceMonthlyWeek) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceMonthlyWeek requires RecurrenceType to be set to 3 (Monthly).'
        }
        
        if ($RecurrenceEndTimes =and $RecurrenceEndDateTime) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceEndDateTime cannot be used in conjunction with RecurrenceEndTimes.'
        }
        
        if (-not $Recurrence) {
            $Recurrence = @{}
        }

        #Sets $RecurrenceEndTimes to 1 if no value is provided for $RecurrenceEndTimes or $RecurrenceEndDatetime. This is in line with Zoom's documentaiton which declares a default value for EndTimes.
        if ($RecurrenceEndTimes) {
                Recurrence.Add('end_times', $RecurrenceEndTimes)
        } elseif ($RecurrenceEndDateTime) {
                Recurrence.Add('end_date_time', $RecurrenceEndDateTime)
        } else {
            $RecurrenceEndTimes = 1  
            Recurrence.Add('end_times', $RecurrenceEndTimes)
        }

        #Default values for recurrence
        Recurrence.Add('type', $RecurrenceType)
        Recurrence.Add('repeat_interval', $RecurrenceRepeatInterval)
        
        if ($RecurrenceWeeklyDays) {
            Recurrence.Add('weekly_days', $RecurrenceWeeklyDays)
        }elseif ($RecurrenceMonthlyDay) {
            Recurrence.Add('monthly_day', $RecurrenceMonthlyDay)
        }elseif ($RecurrenceMonthlyWeek) {
            Recurrence.Add('monthly_week', $RecurrenceMonthlyWeek)
            Recurrence.Add('monthly_weekday', $RecurrenceMonthlyWeekDay)
        }

        $RequestBody.Add('recurrence', $Recurrence)
    }

    if (-not $Settings) {
        $Settings = @{}
    }

    $AllSettings = @{
        'host_video'              = $HostVideo
        'cn_meeting'              = $CNMeeting
        'in_meeting'              = $INMeeting
        'join_before_host'        = $JoinBeforeHost
        'mute_upon_entry'         = $Mutentry
        'watermark'               = $Watermark
        'use_pmi'                 = $UsePMI
        'approval_type'           = $ApprovalType
        'registration_type'       = $RegistrationType
        'audio'                   = $Audio
        'auto_recording'          = $AutoRecording
        'enforce_login'           = $Enfogin
        'enforce_login_domains'   = $EnforceLoginDomains
        'alternative_hosts'       = $AlternativeHosts
        'close_registration'      = $CloseRegistration
        'waiting_room'            = $WaitingRoom
        'global_dialin_countries' = $GlobalDialInCountries
        'contact_name'            = $ContactName
        'contact_email'           = $ContacEmail
    }

    #Adds additional setting parameters to Settings object, makes sure settuimg was not entered already from settings object
    $AllSettings.Keys | ForEach-Object {
        if ($null -ne $AllSettings.$_) {
            if (-not $settings.Contains($_)) {
                $settings.Add($_, $AllSettings.$_)
            }
        }
    }

    $RequestBody.Add('settings', $Settings)

    Write-Output $PSCmdlet.ParameterSetName, $RequestBody, $Settings, $Recurrence

    <#    
        $Result = Invoke-RestMethod -Uri $Endpoint -Body $RequestBody -Method Post |
                Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Endpoint
    #>

  }
  
  end {
  }
}

$params = @{
    ApiKey                = 'apikey123' 
    ApiSecret             = 'apisecret123' 
    ScheduleFor           = 'jmcevoy@gmail.com' 
    Topic                 = 'Powershell Test' 
    StartTime             = 5
    Duration              = 60
    Type                  = 3
    RecurrenceType       = 3
    Timezone              = 'EST' 
    Password              = '123' 
    Agenda                = 'Test Agenda' 
    HostVideo             = $true 
    CNMeeting             = $false 
    INMeeting             = $false 
    JoinBeforeHost        = $false 
    MuteUponEntry         = $false 
    Watermark             = $false 
    UsePMI                = $false 
    ApprovalType          = 2 
    RegistrationType      = 1
    Audio                 = 'both' 
    AutoRecording         = 'cloud' 
    EnforceLogin          = $false 
    EnforceLoginDomains   = $false 
    AlternativeHosts      = '896712' 
    CloseRegistration     = $false 
    WaitingRoom           = $false
    GlobalDialInCountries = 'France, UK' 
    ContactName           = 'Joseph Mcevoy' 
    ContactEmail          = 'joe.maci@gmail.com'
    <#[-TrackingFields <hashtable[]>]#> <#[-Recurrence <hashtable>]#> <#[-Settings <hashtable>]#> `
}

new-zoommeeting @params