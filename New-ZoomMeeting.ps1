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
    Recurrence object.

    .PARAMETER RecurrenceType
    Recurrence meeting types: 
    1 - Daily
    2 - Weekly
    3 - Monthly

    .PARAMETER RecurrenceRepeatInterval
    At which interval should the meeting repeat? For a daily meeting there's a maximum of 90 days. For a weekly meeting there is a maximum of 12 weeks. 
    For a monthly meeting there is a maximum of 3 months.

    .PARAMETER RecurrenceWeeklyDays
    Days of the week the meeting should repeat. Note: Multiple values should be separated by a comma. 
    1  - Sunday. 2 - Monday. 3 - Tuesday. 4 -  Wednesday. 5 -  Thursday. 6 - Friday. 7 - Saturday.
    
    .PARAMETER RecurrenceMonthlyDay
    Day in the month the meeting is to be scheduled. The value is from 1 to 31.

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
                      

  [CmdletBinding(DefaultParameterSetName='NoRecurrence')]
  param (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiIKey,

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

    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [string]$StartTime,

    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [int]$Duration,

    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
    [string]$Timezone,

    [ValidatePattern("[A-Za-z0-9@-_\*]*")]
    [string]$Password,

    [string]$Agenda,

    [hashtable[]]$TrackingFields,

    [Parameter(Mandatory=$True, ParameterSetName='Recurrence')]
    [hashtable]$Recurrence,

    [Parameter(Mandatory=$True, ParameterSetName='Recurrence')]
    [ValidateRange(1,3)]
    [int]$RecurrenceType,

    [Parameter(Mandatory=$True, ParameterSetName='Recurrence')]
    [int]$RecurrenceRepeatInterval,

    [Parameter(Mandatory=$True, ParameterSetName='Recurrence')]
    [ValidateRange(1,7)]
    [int]$RecurrenceWeeklyDays,

    [Parameter(Mandatory=$True, ParameterSetName='Recurrence')]
    [ValidateRange(1,31)]
    [int]$RecurrenceMonthlyDay,

    [Parameter(Mandatory=$True, ParameterSetName='Recurrence')]
    [ValidateSet(-1,1,2,3,4)]
    [int]$RecurrenceMonthlyWeek,

    [Parameter(ParameterSetName='Recurrence')]
    [ValidateRange(1,7)]
    [int]$RecurrenceMonthlyWeekDay,

    [Parameter(ParameterSetName='Recurrence')]
    [ValidateRange(1,50)]
    [int]$RecurrenceEndTimes = 1,

    #Example: 2016-04-06T10:10:09Z. Regex takenf rom https://www.regextester.com/94925
    [Parameter(ParameterSetName='Recurrence')]
    [ValidatePattern("^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z)?$")] 
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

    [string]$EnforceLoginDomains,

    [string]$AlternativeHosts,

    [bool]$CloseRegistration = $false,

    [bool]$WaitingRoom = $false,

    [string[]]$GlobalDialInCountries,

    [string]$ContactName,

    [string]$ContacEmail
  )
  
  begin {
  }
  
  process {
    $RequestBody = @{
        'api_key'      = $ApiKey
        'api_secret'   = $ApiSecret
        'schedule_for' = $ScheduleFor
        'topic'        = $Topic
        'type'         = $Type
        'start_time'   = $StartTime
        'duration'     = $Duration
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
    
    $RecurrenceBody = @{}

    if ($Recurrence) {
        $RequestBody.Add('reccurence', $Recurrence)
    } else {
        if ($RecurrenceType) {
            RecurrenceBody.Add('type', $RecurrenceType)
        }
        if ($RecurrenceRepeatInterval) {
            RecurrenceBody.Add('_repeat_interval', $RecurrenceRepeatInterval)
        }
        if ($RecurrenceWeeklyDays) {
            RecurrenceBody.Add('weeklydays', $RecurrenceWeeklyDays)
        }
        if ($RecurrenceMonthlyDay) {
            RecurrenceBody.Add('monthlyday', $RecurrenceMonthlyDay)
        }
        if ($RecurrenceMonthlyWeek) {
            RecurrenceBody.Add('monthlyweek', $RecurrenceMonthlyWeek)
        }
        if ($RecurrenceMonthlyWeekDay) {
            RecurrenceBody.Add('monthlyweekday', $RecurrenceMonthlyWeekDay)
        }
        if ($RecurrenceEndTimes) {
            RecurrenceBody.Add('endtimes', $RecurrenceEndTimes)
        }
        if ($RecurrenceEndDateTime) {
            RecurrenceBody.Add('enddatetime', $RecurrenceEndDateTime)
        }
    }

    $SettingsBody = @{}
    if ($Settings) {
        $RequestBody.Add('settings', $Settings)
    }
    if ($HostVideo) {
        $RequestBody.Add('hostvideo', $HostVideo)
    }
    if ($CNMeeting) {
        $RequestBody.Add('cnmeeting', $CNMeeting)
    }
    if ($INMeeting) {
        $RequestBody.Add('inmeeting', $INMeeting)
    }
    if ($JoinBeforeHost) {
        $RequestBody.Add('joinbeforehost', $JoinBeforeHost)
    }
    if ($MuteUponEntry) {
        $RequestBody.Add('muteuponentry', $MuteUponEntry)
    }
    if ($Watermark) {
        $RequestBody.Add('watermark', $Watermark)
    }
    if ($UsePMI) {
        $RequestBody.Add('usepmi', $UsePMI)
    }
    if ($ApprovalType) {
        $RequestBody.Add('approvaltype', $ApprovalType)
    }
    if ($RegistrationType) {
        $RequestBody.Add('registrationtype', $RegistrationType)
    }
    if ($Audio) {
        $RequestBody.Add('audio', $Audio)
    }
    if ($AutoRecording) {
        $RequestBody.Add('autorecording', $AutoRecording)
    }
    if ($EnforceLogin) {
        $RequestBody.Add('enforcelogin', $EnforceLogin)
    }
    if ($EnforceLoginDomains) {
        $RequestBody.Add('enforcelogindomains', $EnforceLoginDomains)
    }
    if ($AlternativeHosts) {
        $RequestBody.Add('alternativehosts', $AlternativeHosts)
    }
    if ($CloseRegistration) {
        $RequestBody.Add('closeregistration', $CloseRegistration)
    }
    if ($WaitingRoom) {
        $RequestBody.Add('waitingroom', $WaitingRoom)
    }
    if ($GlobalDialInCountries) {
        $RequestBody.Add('globaldialincountries', $GlobalDialInCountries)
    }
    if ($ContactName) {
        $RequestBody.Add('contactname', $ContactName)
    }
    if ($ContacEmail) {
        $RequestBody.Add('contacemail', $ContacEmail)
    }
    
    $Result = Invoke-RestMethod -Uri $Endpoint -Body $RequestBody -Method Post |
            Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Endpoint

  }
  
  end {
  }
}