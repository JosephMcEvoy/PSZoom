$ApiKey = '' 
$ApiSecret = ''

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
    Meeting settings.

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
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey,

    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiSecret,
    
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$ScheduleFor,

    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$Topic,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [ValidateSet(1,2,3,8)]
    [ValidateNotNullOrEmpty()]
    [int[]]$Type = 2,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateScript({
        if ($Type -eq 1){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter StartTime cannot be used with Type 1 (Instant Meeting).'
        }
    })]
    [string]$StartTime,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [int]$Duration,

    [Parameter(ValueFromPipelineByPropertyName=$True)]
    [string]$Timezone,

    [ValidatePattern("[A-Za-z0-9@-_\*]*")]
    [string]$Password,

    [string]$Agenda,

    [hashtable[]]$TrackingFields,

    [ValidateScript({
        if ($Type -eq 1 -or $Type -eq 2){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter Recurrence requres Type to be set to 3(Recurring meeting with no fixed time) or 8 (Recurring meeting with fixed time).'
        }
    })]
    [hashtable]$Recurrence,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,3)]
    [ValidateScript({
        if ($Type -eq 1 -or $Type -eq 2){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceType requres Type to be set to 3(Recurring meeting with no fixed time) or 8 (Recurring meeting with fixed time).'
        }
    })]
    [int]$RecurrenceType,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,90)]
    [ValidateScript({
        if ($RecurrenceType -eq 2 -and $_ -le 12){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceRepeatInterval only accepts values between 1 and 12 when RecurrenceType is set to 2 (Weekly).'
        } elseif ($RecurrenceType -eq 3 -and $_ -le 3){
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceRepeatInterval only accepts values between 1 and 3 when RecurrenceType is set to 3 (Monthly).'
        } else {
            $true
        }
    })]
    [int]$RecurrenceRepeatInterval,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [ValidateRange(1,7)]
    [ValidateScript({
        if ($RecurrenceType -ne 2) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceWeeklyDays requires RecurrenceType to be set to 2 (Weekly).'
        }
    })]
    [int[]]$RecurrenceWeeklyDays,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [ValidateRange(1,31)]
    [ValidateScript({
        if ($RecurrenceType -ne 3) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceMonthlyDay requires RecurrenceType to be set to 3 (Monthly).'
        }
    })]
    [int]$RecurrenceMonthlyDay,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateSet(-1,1,2,3,4)]
    [ValidateScript({
        if ($RecurrenceType -ne 3) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceMonthlyDay requires RecurrenceType to be set to 3 (Monthly).'
        }
    })]
    [int]$RecurrenceMonthlyWeek,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,7)]
    [int]$RecurrenceMonthlyWeekDay,

    [Parameter(ParameterSetName='RecurrenceByDay')]
    [Parameter(ParameterSetName='RecurrenceByWeek')]
    [Parameter(ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,50)]
    [ValidateScript({
        if ($RecurrenceEndDateTime) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceEndTimes cannot be used in conjunction with RecurrenceEndDateTime.'
        }
    })]
    [int]$RecurrenceEndTimes,
    
    [Parameter(ParameterSetName='RecurrenceByDay')]
    [Parameter(ParameterSetName='RecurrenceByWeek')]
    [Parameter(ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(ParameterSetName='RecurrenceByMonthWeek')]
    [ValidatePattern("^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z)?$")] 
    #Example: 2016-04-06T10:10:09Z. Regex taken from https://www.regextester.com/94925
    [ValidateScript({
        if ($RecurrenceEndTimes) {
            Throw [System.Management.Automation.ValidationMetadataException] 'Parameter RecurrenceEndDateTime cannot be used in conjunction with RecurrenceEndTimes.'
        }
    })]
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
    $RequestBody = @{
        'api_key'      = $ApiKey
        'api_secret'   = $ApiSecret
        'schedule_for' = $ScheduleFor
        'topic'        = $Topic
    }
    if ($Type) {
        $RequestBody.Add('type', $Type)
    }
    if ($StartTime) {
        $RequestBody.Add('start_time', $StartTime)
    }
    if ($Duration) {
        $RequestBody.Add('duration', $Duration)
    }
    if ($Timezone) {
        $RequestBody.Add('timezone', $Timezone)
    }
    if ($Password) {
        $RequestBody.Add('password', $Password)
    }
    if ($Agenda) {
        $RequestBody.Add('agenda', $Agenda)
    }
    if ($TrackingFields) {
        $RequestBody.Add('tracking_fields', $TrackingFields)
    }
    
    $RecurrenceObject = @{}

    #Sets default to 1 if neither value is provided
    if (('RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {
        if (-not $RecurrenceEndTimes -and -not $RecurrenceEndDateTime) {
            $RecurrenceEndTimes = 1 
        }
    }
    


    if ($Recurrence) {
        $RequestBody.Add('reccurence', $Recurrence)
    } else {
        if ($RecurrenceType) {
            RecurrenceObject.Add('type', $RecurrenceType)
        }
        if ($RecurrenceRepeatInterval) {
            RecurrenceObject.Add('repeat_interval', $RecurrenceRepeatInterval)
        }
        if ($RecurrenceWeeklyDays) {
            RecurrenceObject.Add('weekly_days', $RecurrenceWeeklyDays)
        }
        if ($RecurrenceMonthlyDay) {
            RecurrenceObject.Add('monthly_day', $RecurrenceMonthlyDay)
        }
        if ($RecurrenceMonthlyWeek) {
            RecurrenceObject.Add('monthly_week', $RecurrenceMonthlyWeek)
        }
        if ($RecurrenceMonthlyWeekDay) {
            RecurrenceObject.Add('monthly_weekday', $RecurrenceMonthlyWeekDay)
        }
        if ($RecurrenceEndTimes) {
            RecurrenceObject.Add('end_times', $RecurrenceEndTimes)
        }
        if ($RecurrenceEndDateTime) {
            RecurrenceObject.Add('end_date_time', $RecurrenceEndDateTime)
        }
        if ($RecurrenceObject -ne $Null) {
            $RequestBody.Add('recurrence', $RecurrenceObject)
        }
    }

    $SettingsObject = @{}

    if ($Settings) {
        $RequestBody.Add('settings', $Settings)
    } else {
        if ($HostVideo) {
            $SettingsObject.Add('host_video', $HostVideo)
        }
        if ($CNMeeting) {
            $SettingsObject.Add('cn_meeting', $CNMeeting)
        }
        if ($INMeeting) {
            $SettingsObject.Add('in_meeting', $INMeeting)
        }
        if ($JoinBeforeHost) {
            $SettingsObject.Add('join_before_host', $JoinBeforeHost)
        }
        if ($MuteUponEntry) {
            $SettingsObject.Add('mute_upon_entry', $MuteUponEntry)
        }
        if ($Watermark) {
            $SettingsObject.Add('watermark', $Watermark)
        }
        if ($UsePMI) {
            $SettingsObject.Add('use_pmi', $UsePMI)
        }
        if ($ApprovalType) {
            $SettingsObject.Add('approval_type', $ApprovalType)
        }
        if ($RegistrationType) {
            $SettingsObject.Add('registration_type', $RegistrationType)
        }
        if ($Audio) {
            $SettingsObject.Add('audio', $Audio)
        }
        if ($AutoRecording) {
            $SettingsObject.Add('auto_recording', $AutoRecording)
        }
        if ($EnforceLogin) {
            $SettingsObject.Add('enforce_login', $EnforceLogin)
        }
        if ($EnforceLoginDomains) {
            $SettingsObject.Add('enforce_login_domains', $EnforceLoginDomains)
        }
        if ($AlternativeHosts) {
            $SettingsObject.Add('alternative_hosts', $AlternativeHosts)
        }
        if ($CloseRegistration) {
            $SettingsObject.Add('close_registration', $CloseRegistration)
        }
        if ($WaitingRoom) {
            $SettingsObject.Add('waiting_room', $WaitingRoom)
        }
        if ($GlobalDialInCountries) {
            $SettingsObject.Add('global_dialin_countries', $GlobalDialInCountries)
        }
        if ($ContactName) {
            $SettingsObject.Add('contact_name', $ContactName)
        }
        if ($ContactEmail) {
            $SettingsObject.Add('contact_email', $ContacEmail)
        }
        if ($SettingsObject -ne $Null) {
            $RequestBody.Add('settings', $SettingsObject)
        }
    }

    Write-Output $RequestBody,$RecurrenceObject,$SettingsObject

    <#    
        $Result = Invoke-RestMethod -Uri $Endpoint -Body $RequestBody -Method Post |
                Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Endpoint
    #>

  }
  
  end {
  }
}

new-zoommeeting -ApiKey 'apikey123' -ApiSecret 'apisecret123' -ScheduleFor 'jmcevoy@gmail.com' -Topic 'Powershell Test' -StartTime "1970-01-01 00:00:00Z" -Duration 60 `
-Type 2 -Timezone 'EST' -Password '123' -Agenda 'Test Agenda' <#[-TrackingFields <hashtable[]>]#> <#[-Recurrence <hashtable>]#> <#[-Settings <hashtable>]#> `
-HostVideo $true -CNMeeting $false -INMeeting $false -JoinBeforeHost $false -MuteUponEntry $false -Watermark $false -UsePMI $false -ApprovalType 2 -RegistrationType 1 `
-Audio 'both' -AutoRecording 'cloud' -EnforceLogin $false -EnforceLoginDomains $false -AlternativeHosts '896712' -CloseRegistration $false -WaitingRoom $false `
-GlobalDialInCountries 'France, UK' -ContactName 'Joseph Mcevoy' -ContactEmail 'joe.maci@gmail.com'
