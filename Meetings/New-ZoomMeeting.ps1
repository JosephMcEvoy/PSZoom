<#

.SYNOPSIS
Create a meeting for a user.
.DESCRIPTION
Create a meeting for a user. The expiration time for the start_url object is two hours. For API users, the expiration time is 90 days.
.PARAMETER UserId
The user ID or email address.
.PARAMETER ScheduleFor
Email or userId if you want to schedule meeting for another user.
.PARAMETER Topic
Meeting topic.
.PARAMETER Type
Meeting type. 
Instant meeting (1)
Scheduled meeting (2)
Recurring meeting with no fixed time (3)
Recurring meeting with fixed time. (8)
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
Daily (1)
Weekly (2)
Monthly (3)
.PARAMETER RecurrenceRepeatInterval
At which interval should the meeting repeat? For a daily meeting there's a maximum of 90 days. 
For a weekly meeting there is a maximum of 12 weeks. 
For a monthly meeting there is a maximum of 3 months.
.PARAMETER RecurrenceWeeklyDays
Days of the week the meeting should repeat. Note: Multiple values should be separated by a comma. 
Sunday (1)
Monday (2)
Tuesday (3)
Wednesday (4)
Thursday (5)
Friday (6)
Saturday (7)
.PARAMETER RecurrenceMonthlyDay
Day in the month the meeting is to be scheduled. The value is from 1 to 31.
.PARAMETER RecurrenceMonthlyWeek
The week a meeting will recur each month.
Last week (-1)
First week (1)
Second week (2)
Third week (3)
Fourth week (4)
.PARAMETER RecurrenceMonthlyWeekDay
The weekday a meeting should recur each month.
Sunday (1)
Monday (2)
Tuesday (3)
Wednesday (4)
Thursday (5)
Friday (6)
Saturday (7)
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
Automatic - Automatically approve (0)
Manual - Manually approve (1)
None - No registration required (2)
.PARAMETER RegistrationType
Registration type. Used for recurring meeting with fixed time only. 
RegisterOnceAndAttendAll' - Attendees register once and can attend any of the occurrences.(1)
RegisterForEachOccurence' - Attendees need to register for each occurrence to attend.(2)
RegisterOnceAndChooseOccurences' - Attendees register once and can choose one or more occurrences to attend.(3)
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
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
The API secret.
.LINK
https://github.com/JosephMcEvoy/New-ZoomMeeting
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/meetings/meetingcreate
.LINK
https://marketplace.zoom.us/docs/api-reference/introduction
#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"
. "$PSScriptRoot\Get-ZoomMeeting.ps1"

function New-ZoomMeeting {
  [CmdletBinding(DefaultParameterSetName="Instant")]
  param (
    [Parameter(Mandatory=$True, ParameterSetName='Instant')]
    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateNotNullOrEmpty()]
    [string]$UserId,

    [Parameter(Mandatory=$True, ParameterSetName='Instant')]
    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateNotNullOrEmpty()]
    [string]$ScheduleFor,

    [Parameter(Mandatory=$True, ParameterSetName='Instant')]
    [Parameter(Mandatory=$True, ParameterSetName='ScheduledMeeting')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string]$Topic,

    [Parameter(ParameterSetName='Instant')]
    [Parameter(ParameterSetName='ScheduledMeeting')]
    [Parameter(ParameterSetName='RecurrenceByDay')]
    [Parameter(ParameterSetName='RecurrenceByWeek')]
    [Parameter(ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateSet('Instant', 'Scheduled', 'RecurringNoFixedTime', 'RecurringFixedTime', 1, 2, 3, 8)]
    [ValidateNotNullOrEmpty()]
    [string]$Type = 'Scheduled',

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

    [ValidatePattern("[A-Za-z0-9@\-_\*]{1,10}")] #Letters, numbers, '@', '-', '_', '*' from 1 to 10 chars
    [string]$Password,

    [string]$Agenda,

    [hashtable[]]$TrackingFields,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateSet('Daily', 'Weekly', 'Monthly', 1, 2, 3)]
    [string]$RecurrenceType,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateRange(1,90)]
    [int]$RecurrenceRepeatInterval,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByWeek')]
    [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 1, 2, 3, 4, 5, 6, 7)]
    [string[]]$RecurrenceWeeklyDays,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthDay')]
    [ValidateRange(1,31)]
    [int]$RecurrenceMonthlyDay,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateSet('LastWeek', 'FirstWeek', 'SecondWeek', 'ThirdWeek', 'FourthWeek')]
    [string]$RecurrenceMonthlyWeek,

    [Parameter(Mandatory=$True, ParameterSetName='RecurrenceByMonthWeek')]
    [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 1, 2, 3, 4, 5, 6, 7)]
    [string]$RecurrenceMonthlyWeekDay,

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

    [bool]$HostVideo,

    [bool]$CNMeeting = $false,

    [bool]$INMeeting = $false,

    [bool]$JoinBeforeHost = $false,

    [bool]$MuteUponEntry = $false,

    [bool]$Watermark = $false,

    [bool]$UsePMI = $false,

    [ValidateSet('Automatic', 'Manual', 'None', 0, 1, 2)]
    [string]$ApprovalType = 'None',

    [ValidateSet('RegisterOnceAndAttendAll', 'RegisterForEachOccurence', 'RegisterOnceAndChooseOccurences', 0, 1, 2)]
    [string]$RegistrationType = 'RegisterOnceAndAttendAll',

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

    [string]$ContactEmail,

    [string]$ApiKey,

    [string]$ApiSecret
  )
  
  begin {
    $Uri = "https://api.zoom.us/v2/users/$userId/meetings"

    #Get Zoom Api Credentials
    if (-not $ApiKey -or -not $ApiSecret) {
        $ApiCredentials = Get-ZoomApiCredentials
        $ApiKey = $ApiCredentials.ApiKey
        $ApiSecret = $ApiCredentials.ApiSecret
    }

    #Generate Headers with JWT (JSON Web Token)
    $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
  }
  
  process {
    
    $Type = switch ($Type) {
        'Instant'              { '1' }
        'Scheduled'            { '2' }
        'RecurringNoFixedTime' { '3' }
        'RecurringFixedTime'   { '8' }
    }

    # Additional StartTime and Duration parameter validation
    if (($Type -eq 1) -and ($StartTime -or $Duration)){
        Throw [System.Management.Automation.ValidationMetadataException] 'Parameter StartTime cannot be used with Type 1 (Instant Meeting).'
    }

    #The following parameters are added by default as they are requierd by all parameter sets so they are automatically added to the request body
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

    #If values in OptinalParameters exist, add them to the request
    $OptionalParameters.Keys | ForEach-Object {
        if ($null -ne $OptionalParameters.$_) {
            $RequestBody.Add($_, $OptionalParameters.$_)
        }
    }

    ##### Scheduled Meetings Begin #####
    #The following parameters are mandatory for 5 parameter sets. If one of these parameter sets is being used, the corresponding keys are added to the RequestBody
    if (('ScheduledMeeting', 'RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {
        $RequestBody.Add('start_time', $StartTime)
        $RequestBody.Add('duration', $Duration)
    }


    if (('RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {
        $RecurrenceType = switch ($RecurrenceType) {
            "Daily"   { '1' }
            "Weekly"  { '2' }
            "Monthly" { '3' }
        }

        if ($RecurrenceWeeklyDays) {
            $RecurrenceWeeklyDays | ForEach-Object {
                $RecurrenceWeeklyDays[$RecurrenceWeeklyDays.IndexOf($_)] = switch ($_) { #loops through each day and changes it because this parameter is an array
                    'Sunday'    { '1' }
                    'Monday'    { '2' }
                    'Tuesday'   { '3' }
                    'Wednesday' { '4' }
                    'Thursday'  { '5' }
                    'Friday'    { '6' }
                    'Saturday'  { '7' }
                }
            }
        }

        if ($RecurrenceMonthlyWeek) {
            $RecurrenceMonthlyWeek = switch ($RecurrenceMonthlyWeek) {
                'LastWeek'   { '-1' }
                'FirstWeek'  { '1' }
                'SecondWeek' { '2' }
                'ThirdWeek'  { '3' }
                'FourthWeek' { '4' }
            }
        }

        if ($RecurrenceMonthlyWeekDay) {
            $RecurrenceMonthlyWeekDay = switch ($_) {
                'Sunday'    { '1' }
                'Monday'    { '2' }
                'Tuesday'   { '3' }
                'Wednesday' { '4' }
                'Thursday'  { '5' }
                'Friday'    { '6' }
                'Saturday'  { '7' }
            }
        }

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
        
        $Recurrence = @{}

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

        $RequestBody.Add('recurrence', ($Recurrence | ConvertTo-Json))
    }
    ##### Scheduled Meetings End #####

    #### Misc Settings Start #####
    $Settings = @{}

    if ($ApprovalType) {
        $ApprovalType = switch ($ApprovalType) {
            'Automatic' { '0' }
            'Manual'    { '1' }
            'None'      { '2' }
            Default     { '2' }
        }
    }

    if ($RegistrationType) {
        $RegistrationType = switch ($RegistrationType) {
            'RegisterOnceAndAttendAll' { '1' }
            'RegisterForEachOccurence' { '2' }
            'RegisterOnceAndChooseOccurences' { '3' }
        }
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

    if ($Settings.Count -gt 0) {
        $RequestBody.Add('settings', $Settings)
    }
    #### Misc Settings End #####

    try {
        $Response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method Post
    } catch {
        Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
    }

    Write-Output $Response
  }

}
#Example Params
<#
$paramsScheduled = @{
    UserId                = 'jmcevoy@lawfirm.com'
    ScheduleFor           = 'jmcevoy@lawfirm.com' 
    Topic                 = 'Powershell Test' 
    #StartTime             = "2019-06-23'T'04:00:00'Z'\"
    #Duration              = 60
    Type                  = 'Instant'
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
    ApprovalType          = 'Automatic'
    RegistrationType      = 'RegisterForEachOccurence'
    Audio                 = 'both' 
    AutoRecording         = 'cloud' 
    EnforceLogin          = $false 
    EnforceLoginDomains   = $false 
    AlternativeHosts      = '896712' 
    CloseRegistration     = $false 
    WaitingRoom           = $false
    ContactName           = 'Joseph Mcevoy' 
    ContactEmail          = 'jmcevoy@lawfirm.com'
}

New-ZoomMeeting @paramsScheduled
#>
#show-command new-zoommeeting