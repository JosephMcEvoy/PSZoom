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
.PARAMETER RepeatInterval
At which interval should the meeting repeat? For a daily meeting there's a maximum of 90 days. 
For a weekly meeting there is a maximum of 12 weeks. 
For a monthly meeting there is a maximum of 3 months.
.PARAMETER WeeklyDays
Days of the week the meeting should repeat. Note: Multiple values should be separated by a comma. 
Sunday (1)
Monday (2)
Tuesday (3)
Wednesday (4)
Thursday (5)
Friday (6)
Saturday (7)
.PARAMETER MonthlyDay
Day in the month the meeting is to be scheduled. The value is from 1 to 31.
.PARAMETER MonthlyWeek
The week a meeting will recur each month.
Last week (-1)
First week (1)
Second week (2)
Third week (3)
Fourth week (4)
.PARAMETER MonthlyWeekDay
The weekday a meeting should recur each month.
Sunday (1)
Monday (2)
Tuesday (3)
Wednesday (4)
Thursday (5)
Friday (6)
Saturday (7)
.PARAMETER EndTimes
Select how many timse the meeting will recur before it is canceled. (Cannot be used with "EndDateTime".)
.PARAMETER EndDateTime
Select a date the meeting will recur before it is canceled. Should be in UTC time, such as 2017-11-25T12:00:00Z. (Cannot be used with "EndTimes".)
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

function New-ZoomMeeting {
    [CmdletBinding(DefaultParameterSetName = "Instant")]
    param (
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Instant', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'ScheduledMeeting', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceNoFixedTime', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('user_id', 'id')]
        [string]$UserId,
  
        [Parameter(
            ParameterSetName = 'Instant', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'ScheduledMeeting', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceNoFixedTime', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_for')]
        [string]$ScheduleFor,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Instant', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'ScheduledMeeting', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceNoFixedTime', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Topic,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'ScheduledMeeting', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('start_time')]
        [string]$StartTime,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'ScheduledMeeting')]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByDay')]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByWeek')]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthDay')]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek')]
        [int]$Duration,

        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceNoFixedTime', 
            ValueFromPipelineByPropertyName = $True
        )]
        [switch]$RecurrenceNoFixedTime,
  
        [string]$Timezone,
  
        [ValidatePattern("[A-Za-z0-9@\-_\*]{1,10}")] #Letters, numbers, '@', '-', '_', '*' from 1 to 10 chars
        [string]$Password,
  
        [string]$Agenda,
  
        [Alias('tracking_fields')]
        [hashtable[]]$TrackingFields,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1, 90)]
        [Alias('recurrence_repeat_interval', 'repeat_interval')]
        [int]$RepeatInterval,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 1, 2, 3, 4, 5, 6, 7)]
        [Alias('recurrence_weekly_days', 'weekly_days', 'recurrenceweeklydays')]
        [string[]]$WeeklyDays,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1, 31)]
        [Alias('recurrence_monthly_day', 'monthly_day', 'recurrencemonthlyday')]
        [int]$MonthlyDay,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('LastWeek', 'FirstWeek', 'SecondWeek', 'ThirdWeek', 'FourthWeek', -1, 1, 2, 3, 4)]
        [Alias('recurrence_monthly_week', 'monthly_week')]
        [string]$MonthlyWeek,
  
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 1, 2, 3, 4, 5, 6, 7)]
        [Alias('recurrence_monthly_weekday')]
        [string]$MonthlyWeekDay,
  
        [Parameter(
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1, 50)]
        [Alias('recurrence_end_times', 'end_times', 'endafter')]
        [int]$EndTimes,
      
        [Parameter(
            ParameterSetName = 'RecurrenceByDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByMonthDay', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = 'RecurrenceByMonthWeek', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('recurrence_end_datetime', 'end_date_time', 'endafterdatetime')]
        [string]$EndDateTime,

        #Settings
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('host_video')]
        [bool]$HostVideo,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('cn_meeting')]
        [bool]$CNMeeting = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('in_meeting')]
        [bool]$INMeeting = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('join_before_host')]
        [bool]$JoinBeforeHost = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('mute_before_entry')]
        [bool]$MuteUponEntry = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Watermark = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('use_pmi')]
        [bool]$UsePMI = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Automatic', 'Manual', 'None', 0, 1, 2)]
        [Alias('approval_type')]
        [string]$ApprovalType = 'None',
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('RegisterOnceAndAttendAll', 'RegisterForEachOccurence', 'RegisterOnceAndChooseOccurences', 0, 1, 2)]
        [Alias('registration_type')]
        [string]$RegistrationType = 'RegisterOnceAndAttendAll',
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('both', 'telephony', 'voip')]
        [string]$Audio,
  
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('local', 'cloud', 'none')]
        [Alias('auto_recording')]
        [string]$AutoRecording = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('enforce_login')]
        [bool]$EnforceLogin,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('enforce_login_domains')]
        [bool]$EnforceLoginDomains,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('alternative_hosts')]
        [string]$AlternativeHosts,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('close_registration')]
        [bool]$CloseRegistration = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('waiting_room')]
        [bool]$WaitingRoom = $false,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('global_dialin_countries')]
        [string[]]$GlobalDialInCountries,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('contact_name')]
        [string]$ContactName,
      
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('contact_email')]
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
      
        $Type = switch ($PSCmdlet.ParameterSetName) {
            'Instant'               { 1 }
            'ScheduledMeeting'      { 2 }
            'RecurrenceNoFixedTime' { 3 }
            'RecurrenceByDay'       { 8 }
            'RecurrenceByWeek'      { 8 }
            'RecurrenceByMonthDay'  { 8 }
            'RecurrenceByMonthWeek' { 8 }
        }
    
        #The following parameters are added by default as they are requierd by all parameter sets so they are automatically added to the request body
        $RequestBody = @{
            'api_key'    = $ApiKey
            'api_secret' = $ApiSecret
            'topic'      = $Topic
            'type'       = $Type
        }
  
        function Remove-NonPsBoundParameters {
            <#This function looks at the values of the keys passed to it then determines if they were passed in the process scope.
            Only the parameters that were passed that match the value names are outputted.#>
            param (
                $Obj,
                $Parameters = $PSBoundParameters
            )
  
            process {
                $NewObj = @{ }
      
                foreach ($Key in $Obj.Keys) {
                    if ($Parameters.ContainsKey($Obj.$Key)) {
                        $Newobj.Add($Key, (get-variable $Obj.$Key).value)
                    }
                }
      
                return $NewObj
            }
        }
  
        #These are optional meeting parameters for all parameter sets.
        $OptionalParameters = @{
            'schedule_for'    = 'ScheduleFor'
            'timezone'        = 'Timezone'
            'password'        = 'Password'
            'agenda'          = 'Agenda'
            'tracking_fields' = 'TrackingFields'
        }
  
        $OptionalParameters = Remove-NonPsBoundParameters($OptionalParameters)
  
        $OptionalParameters.Keys | ForEach-Object {
            $RequestBody.Add($_, $OptionalParameters.$_)
        }
  
        ##### Scheduled Meetings Begin #####
        #These parameters are added by default for all scheudle type parameter sets.
        if (('ScheduledMeeting', 'RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {
            $RequestBody.Add('start_time', $StartTime)
            $RequestBody.Add('duration', $Duration)
        }
        
        #This is for recurrence parameter sets.
        if (('RecurrenceByDay', 'RecurrenceByWeek', 'RecurrenceByMonthDay', 'RecurrenceByMonthWeek').Contains($PSCmdlet.ParameterSetName)) {    
            $Recurrence = @{}

            $RecurrenceType = switch ($PSCmdlet.ParameterSetName) {
                'RecurrenceByDay'       { '1' }
                'RecurrenceByWeek'      { '2' }
                'RecurrenceByMonthDay'  { '3' }
                'RecurrenceByMonthWeek' { '3' }
            }

            #Per Zoom API Reference, repeat interval by month has a maximum of 3 and by week has a maximum of 12.
            if ($PSCmdlet.ParameterSetName -eq 'RecurrenceByMonthDay' -or $PSCmdlet.ParameterSetName -eq 'RecurrenceByMonthWeek' ) {
                if ($RepeatInterval -gt 3) {
                    Throw 'Recurrences by month have a max value of 3.'
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'RecurrenceByWeek') {
                if ($RepeatInterval -gt 12) {
                    Throw 'Recurrences by week have a max value of 12.'
                }
            }
            
            if ($PSBoundParameters.ContainsKey('WeeklyDays')) {
                $WeeklyDays | ForEach-Object {
                    #Loops through each day and changes it because this parameter is an array
                    $WeeklyDays[$WeeklyDays.IndexOf($_)] = switch ($_) {
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

            if ($PSBoundParameters.ContainsKey('MonthlyWeek')) {
                $MonthlyWeek = switch ($MonthlyWeek) {
                    'LastWeek'   { '-1' }
                    'FirstWeek'  { '1' }
                    'SecondWeek' { '2' }
                    'ThirdWeek'  { '3' }
                    'FourthWeek' { '4' }
                }
            }

            if ($PSBoundParameters.ContainsKey('MonthlyWeekDay')) {
                $MonthlyWeekDay = switch ($MonthlyWeekDay) {
                    'Sunday'    { '1' }
                    'Monday'    { '2' }
                    'Tuesday'   { '3' }
                    'Wednesday' { '4' }
                    'Thursday'  { '5' }
                    'Friday'    { '6' }
                    'Saturday'  { '7' }
                }
            }
            
            #Default values for recurrence
            $Recurrence = @{
                'type' = $RecurrenceType
                'repeat_interval' = $RepeatInterval   
            }

            #Sets $EndTimes to 1 if no value is provided for $EndTimes or $EndDateTime. This is in line with Zoom's documentaiton which declares a default value for EndTimes.
            if ($PSBoundParameters.ContainsKey('EndTimes')) {
                $Recurrence.Add('end_times', $EndTimes)
                Write-Host "hello"
            } elseif ($PSBoundParameters.ContainsKey('EndDateTime')) {
                $Recurrence.Add('end_date_time', $EndDateTime)
            } else {
                $EndTimes = 1
                $Recurrence.Add('end_times', $EndTimes)
            }

            #These values are mandatory depending on parameter set used
            #For some reason, Zoom requires this to be a string of integers separated by a comma, instead of an array.
            if ($PSBoundParameters.ContainsKey('WeeklyDays')){
                $Recurrence.Add('weekly_days', (ConvertTo-StringWithCommas($WeeklyDays)))
            }

            $RecurrenceSettings = @{
                'monthly_day'     = 'MonthlyDay'
                'monthly_week'    = 'MonthlyWeek'
                'monthly_weekday' = 'MonthlyWeekDay'
            }

            $RecurrenceSettings = Remove-NonPsBoundParameters($RecurrenceSettings)
    
            $RecurrenceSettings.Keys | ForEach-Object {
                $Recurrence.Add($_, $RecurrenceSettings.$_)
            }

            $RequestBody.Add('recurrence', ($Recurrence))
        }
        ##### Scheduled Meetings End #####
  
        #### Misc Settings Start #####  
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
                'RegisterOnceAndAttendAll'        { '1' }
                'RegisterForEachOccurence'        { '2' }
                'RegisterOnceAndChooseOccurences' { '3' }
            }
        }
  
        $Settings = @{
            'alternative_hosts'       = 'AlternativeHosts'
            'approval_type'           = 'ApprovalType'
            'audio'                   = 'Audio'
            'auto_recording'          = 'AutoRecording'
            'close_registration'      = 'CloseRegistration'
            'cn_meeting'              = 'CNMeeting'
            'contact_email'           = 'ContacEmail'
            'contact_name'            = 'ContactName'
            'enforce_login'           = 'Enfogin'
            'enforce_login_domains'   = 'EnforceLoginDomains'
            'global_dialin_countries' = 'GlobalDialInCountries'
            'host_video'              = 'HostVideo'
            'in_meeting'              = 'INMeeting'
            'join_before_host'        = 'JoinBeforeHost'
            'mute_upon_entry'         = 'Mutentry'
            'registration_type'       = 'RegistrationType'
            'use_pmi'                 = 'UsePMI'
            'waiting_room'            = 'WaitingRoom'
            'watermark'               = 'Watermark'
        }
  
        #Adds additional setting parameters to Settings object.
        $Settings = Remove-NonPsBoundParameters($Settings)
  
        $Settings.Keys | ForEach-Object {
            $RequestBody.Add('settings', $Settings)
        }
  
        #### Misc Settings End #####
        
        try {
            $response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method Post
        }
        catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        finally {
            Write-Output $response
        }
        
        #Write-Output $RequestBody | ConvertTo-Json | Set-Clipboard
    }
}
