<#

.SYNOPSIS
Update a user on your account.
.PARAMETER UserId
The user ID or email address.
.PARAMETER HostVideo 
Start meetings with host video on.
.EXAMPLE
Update-ZoomUserSettings -UserId 'jsmith@lawfirm.com'-hostvideo $True
.PARAMETER ParticipantsVideo
Start meetings with participants video on.
.PARAMETER AudioType
Determine how participants can join the audio portion of the meeting.
both - Telephony and VoIP.
telephony - Audio PSTN telephony only.
voip - VoIP only.
thirdParty - Third party audio conference.
.PARAMETER JoinBeforeHost 
Join the meeting before host arrives.
.PARAMETER ForcePmiJbhPassword 
Require a password for personal meetings if attendees can join before host.
.PARAMETER PstnPasswordProtected 
Generate and require password for participants joining by phone.
.PARAMETER UsePmiForScheduledMeetings 
Use Personal Meeting ID (PMI) when scheduling a meeting.
.PARAMETER UsePmiForInstantMeetings 
Use Personal Meeting ID (PMI) when starting an instant meeting.
.PARAMETER E2eEncryption 
End-to-end encryption required for all meetings.
.PARAMETER Chat            
Enable chat during meeting for all participants.
.PARAMETER PrivateChat            
Enable 11 private chat between participants during meetings.
.PARAMETER AutoSavingChat        
Auto save all in-meeting chats.
.PARAMETER EntryExitChim
Play sound when participants join or leave<br>`host` - When host joins or leaves.<br>`all` - When any participant joins or leaves.<br>`none` - No join or leave sound.
.PARAMETER RecordPlayVoice 
Record and play their own voice.
.PARAMETER FileTransfer  
Enable file transfer through in-meeting chat.
.PARAMETER Feedback  
Enable option to send feedback to Zoom at the end of the meeting.
.PARAMETER CoHost  
Allow the host to add co-hosts.
.PARAMETER Polling  
Add polls to the meeting controls.
.PARAMETER AttendeeOnHold  
Allow host to put attendee on hold.
.PARAMETER Annotation  
Allow participants to use annotation tools.
.PARAMETER RemoteControl  
Enable remote control during screensharing.
.PARAMETER NonVerbalFeedback  
Enable non-verbal feedback through screens.
.PARAMETER BreakoutRoom  
Allow host to split meeting participants into separate breakout rooms.
.PARAMETER RemoteSupport  
Allow host to provide 11 remote support to a participant.
.PARAMETER ClosedCaption  
Enable closed captions.
.PARAMETER GroupHd  
Enable group HD video.
.PARAMETER VirtualBackground  
Enable virtual background.
.PARAMETER FarEndCameraControl  
Allow another user to take control of the camera.
.PARAMETER ShareDualCamera  
Share dual camera (deprecated).
.PARAMETER AttentionTracking  
Allow host to see if a participant does not have Zoom in focus during screen sharing.
.PARAMETER WaitingRoom  
Enable Waiting room - if enabled, attendees can only join after host approves.
.PARAMETER AllowLiveStreaming 
Allow live streaming.
.PARAMETER WorkplaceByFacebook 
Allow livestreaming by host through Workplace by Facebook.
.PARAMETER CustomLiveStreaming 
Allow custom live streaming.
.PARAMETER CustomServiceInstructions 
Custom service instructions.
.PARAMETER JbhReminder  
When attendees join meeting before host.
.PARAMETER CancelMeetingReminder  
When a meeting is cancelled.
.PARAMETER AlternativeHostReminder  
When an alternative host is set or removed from a meeting.
.PARAMETER ScheduleForReminder  
Notify the host there is a meeting is scheduled, rescheduled, or cancelled.
.PARAMETER LocalRecording 
Local recording.
.PARAMETER CloudRecording  
Cloud recording.
.PARAMETER RecordSpeakerView  
Record the active speaker view.
.PARAMETER RecordGalleryView  
Record the gallery view.
.PARAMETER RecordAudioFile  
Record an audio only file.
.PARAMETER SaveChatText  
Save chat text from the meeting.
.PARAMETER ShowTimestamp  
Show timestamp on video.
.PARAMETER RecordingAudioTranscript 
Audio transcript.
.PARAMETER AutoRecording
Automatic recording<br>`local` - Record on local.<br>`cloud` - Record on cloud.<br>`none` - Disabled.
.PARAMETER HostPauseStopRecording  
Host can pause/stop the auto recording in the cloud.
.PARAMETER AutoDeleteCmr  
Auto delete cloud recordings.
.PARAMETER AutoDeleteCmrDays 
A specified number of days of auto delete cloud recordings.
.PARAMETER ThirdPartyAudio 
Third party audio conference.
.PARAMETER AudioConferenceInfo
Third party audio conference info.
.PARAMETER ShowInternationalNumbersLink 
Show the international numbers link on the invitation email.
.PARAMETER MeetingCapacity 
User's meeting capacity.
.PARAMETER LargeMeeting 
Large meeting feature.
.PARAMETER LargeMeetingCapacity 
Large meeting capacity can be 500 or 1000, depending on the user has a large meeting capacity plan subscription or not.
.PARAMETER Webinar 
Webinar feature.
.PARAMETER WebinarCapacity 
Webinar capacity can be 100, 500, 1000, 3000, 5000 or 10000, depending on if the user has a webinar capacity plan subscription or not.
.PARAMETER ZoomPhone 
Zoom phone feature.
.PARAMETER CallOut 
Call Out.
.PARAMETER CallOutCountries 
Call Out Countries/Regions. 
.PARAMETER ShowInternationalNumbersLink
Show international numbers link on the invitation email.
#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"
. "$PSScriptRoot\Get-ZoomSpecificUser.ps1"

function Update-ZoomUserSettings {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'EmailAddress', 'Id')]
        [string]$UserId,

        [Parameter(
            HelpMessage = 'Start meetings with host video on.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('host_video')]
        [bool]$HostVideo, 
            
        [Parameter(
            HelpMessage = 'Start meetings with participants video on.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('participants_video')]
        [bool]$ParticipantsVideo, 
    
        [Parameter(
            HelpMessage = 'Determine how participants can join the audio portion of the meeting<br>`both` - Telephony and VoIP.<br>`telephony` - Audio PSTN telephony only.<br>`voip` - VoIP only.<br>`thirdParty` - Third party audio conference.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('both', 'telephony', 'voip', 'thirdparty')]
        [Alias('audio_type')]
        [string]$AudioType, 

        [Parameter(
            HelpMessage = 'Join the meeting before host arrives.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('join_before_host')]
        [bool]$JoinBeforeHost, 
            
        [Parameter(
            HelpMessage = 'Require a password for personal meetings if attendees can join before host.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('force_pmi_jbh_password')]
        [bool]$ForcePmiJbhPassword, 
            
        [Parameter(
            HelpMessage = 'Generate and require password for participants joining by phone.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('pstn_password_protected')]
        [bool]$PstnPasswordProtected, 
            
        [Parameter(
            HelpMessage = 'Use Personal Meeting ID (PMI) when scheduling a meeting\n', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('use_pmi_for_scheduled_meetings')]
        [bool]$UsePmiForScheduledMeetings, 
            
        [Parameter(
            HelpMessage = 'Use Personal Meeting ID (PMI) when starting an instant meeting\n', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('use_pmi_for_instant_meetings')]
        [bool]$UsePmiForInstantMeetings, 

        #inMeeting 
        [Parameter(
            HelpMessage = 'End-to-end encryption required for all meetings.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('e2e_encryption')]
        [bool]$E2eEncryption, 
            
        [Parameter(
            HelpMessage = 'Enable chat during meeting for all participants.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [bool]$Chat,           

        [Parameter(
            HelpMessage = 'Enable 11 private chat between participants during meetings.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('private_chat')]
        [bool]$PrivateChat,           

        [Parameter(
            HelpMessage = 'Auto save all in-meeting chats.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('auto_saving_chat')]
        [bool]$AutoSavingChat,       

        [Parameter(
            HelpMessage = 'Play sound when participants join or leave<br>`host` - When host joins or leaves.<br>`all` - When any participant joins or leaves.<br>`none` - No join or leave sound.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('host', 'all', 'none')]
        [Alias('entry_exit_chime')]
        [string]$EntryExitChime, 

        [Parameter(
            HelpMessage = 'Record and play their own voice.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('record_play_voice')]
        [bool]$RecordPlayVoice, 

        [Parameter(
            HelpMessage = 'Enable file transfer through in-meeting chat.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('file_transfer')]
        [bool]$FileTransfer, 

        [Parameter(
            HelpMessage = 'Enable option to send feedback to Zoom at the end of the meeting.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [bool]$Feedback, 

        [Parameter(
            HelpMessage = 'Allow the host to add co-hosts.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('co_host ')]
        [bool]$CoHost, 

        [Parameter(
            HelpMessage = 'Add polls to the meeting controls.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [bool]$Polling, 

        [Parameter(
            HelpMessage = 'Allow host to put attendee on hold.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('attendee_on_hold')]
        [bool]$AttendeeOnHold, 

        [Parameter(
            HelpMessage = 'Allow participants to use annotation tools.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [bool]$Annotation, 

        [Parameter(
            HelpMessage = 'Enable remote control during screensharing.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('remote_control')]
        [bool]$RemoteControl, 

        [Parameter(
            HelpMessage = 'Enable non-verbal feedback through screens.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('non_verbal_feedback ')]
        [bool]$NonVerbalFeedback, 

        [Parameter(
            HelpMessage = 'Allow host to split meeting participants into separate breakout rooms.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('breakout_room')]
        [bool]$BreakoutRoom, 

        [Parameter(
            HelpMessage = 'Allow host to provide 11 remote support to a participant.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('remote_support')]
        [bool]$RemoteSupport, 

        [Parameter(
            HelpMessage = 'Enable closed captions.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('closed_caption')]
        [bool]$ClosedCaption, 

        [Parameter(
            HelpMessage = 'Enable group HD video.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('group_hd')]
        [bool]$GroupHd, 

        [Parameter(
            HelpMessage = 'Enable virtual background.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('virtual_background')]
        [bool]$VirtualBackground, 

        [Parameter(
            HelpMessage = 'Allow another user to take control of the camera.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('far_end_camera_control')]
        [bool]$FarEndCameraControl, 

        [Parameter(
            HelpMessage = 'Share dual camera (deprecated).', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('share_dual_camera')]
        [bool]$ShareDualCamera, 

        [Parameter(
            HelpMessage = 'Allow host to see if a participant does not have Zoom in focus during screen sharing.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('attention_tracking')]
        [bool]$AttentionTracking, 

        [Parameter(
            HelpMessage = 'Enable Waiting room - if enabled, attendees can only join after host approves.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('waiting_room ')]
        [bool]$WaitingRoom, 

        [Parameter(
            HelpMessage = 'Allow live streaming.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('allow_live_streaming')]
        [bool]$AllowLiveStreaming, 

        [Parameter(
            HelpMessage = 'Allow livestreaming by host through Workplace by Facebook.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('workplace_by_facebook')]
        [bool]$WorkplaceByFacebook, 

        [Parameter(
            HelpMessage = 'Allow custom live streaming.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('custom_live_streaming')]
        [bool]$CustomLiveStreaming, 

        [Parameter(
            HelpMessage = 'Custom service instructions.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('custom_service_instructions')]
        [string]$CustomServiceInstructions, 

        #emailNotification
        [Parameter(
            HelpMessage = 'When attendees join meeting before host.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('jbh_reminder')]
        [bool]$JbhReminder, 

        [Parameter(
            HelpMessage = 'When a meeting is cancelled.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('cancel_meeting_reminder')]
        [bool]$CancelMeetingReminder, 

        [Parameter(
            HelpMessage = 'When an alternative host is set or removed from a meeting.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('alternative_host_reminder')]
        [bool]$AlternativeHostReminder, 
            
        [Parameter(
            HelpMessage = 'Notify the host there is a meeting is scheduled, rescheduled, or cancelled.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('schedule_for_reminder')]
        [bool]$ScheduleForReminder, 
        
        #recording
        [Parameter(
            HelpMessage = 'Local recording.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('local_recording')]
        [bool]$LocalRecording, 

        [Parameter(
            HelpMessage = 'Cloud recording.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('cloud_recording')]
        [bool]$CloudRecording, 

        [Parameter(
            HelpMessage = 'Record the active speaker view.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('record_speaker_view')]
        [bool]$RecordSpeakerView, 

        [Parameter(
            HelpMessage = 'Record the gallery view.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('record_gallery_view')]
        [bool]$RecordGalleryView, 

        [Parameter(
            HelpMessage = 'Record an audio only file.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('record_audio_file')]
        [bool]$RecordAudioFile, 

        [Parameter(
            HelpMessage = 'Save chat text from the meeting.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('save_chat_text')]
        [bool]$SaveChatText, 

        [Parameter(
            HelpMessage = 'Show timestamp on video.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('show_timestamp')]
        [bool]$ShowTimestamp, 

        [Parameter(
            HelpMessage = 'Audio transcript.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('recording_audio_transcript')]
        [bool]$RecordingAudioTranscript, 

        [Parameter(
            HelpMessage = 'Automatic recording<br>`local` - Record on local.<br>`cloud` - Record on cloud.<br>`none` - Disabled.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('local', 'cloud', 'none')]
        [Alias('auto_recording ')]
        [string]$AutoRecording, 

        [Parameter(
            HelpMessage = 'Host can pause/stop the auto recording in the cloud.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('host_pause_stop_recording')]
        [bool]$HostPauseStopRecording, 

        [Parameter(
            HelpMessage = 'Auto delete cloud recordings.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('auto_delete_cmr')]
        [bool]$AutoDeleteCmr, 
        
        [Parameter(
            HelpMessage = 'A specified number of days of auto delete cloud recordings.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(0,60)]
        [Alias('auto_delete_cmr_days')]
        [int]$AutoDeleteCmrDays, 

        #telephony
        [Parameter(
            HelpMessage = 'Third party audio conference.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('third_party_audio')]
        [bool]$ThirdPartyAudio, 

        [Parameter(
            HelpMessage = 'Third party audio conference info.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(0, 2048)]
        [Alias(
            'audio_conference_info ', 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$AudioConferenceInfo, 

        [Parameter(
            HelpMessage = 'Show the international numbers link on the invitation email.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('show_international_numbers_link')]
        [bool]$ShowInternationalNumbersLink, 

        #feature
        [Parameter(
            HelpMessage = "User's meeting capacity.", 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('meeting_capacity')]
        [int]$MeetingCapacity, 

        [Parameter(
            HelpMessage = 'Large meeting feature.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('large_meeting')]
        [bool]$LargeMeeting, 

        [Parameter(
            HelpMessage = 'Large meeting capacity can be 500 or 1000, depending on the user has a large meeting capacity plan subscription or not.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('large_meeting_capacity')]
        [int]$LargeMeetingCapacity, 

        [Parameter(HelpMessage = 'Webinar feature.')]
        [bool]$Webinar, 

        [Parameter(
            HelpMessage = 'Webinar capacity can be 100, 500, 1000, 3000, 5000 or 10000, depending on if the user has a webinar capacity plan subscription or not.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('webinar_capacity')]
        [int]$WebinarCapacity, 

        [Parameter(
            HelpMessage = 'Zoom phone feature.', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('zoom_phone')]
        [bool]$ZoomPhone, 

        #tsp
        [Parameter(
            HelpMessage = 'Call Out', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('call_out')]
        [bool]$CallOut, 

        [Parameter(
            HelpMessage = 'Call Out Countries/Regions', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('call_out_countries')]
        [string[]]$CallOutCountries, 

        [Parameter(
            HelpMessage = 'Show international numbers link on the invitation email', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('feature_show_international_numbers_link')]
        [bool]$FeatureShowInternationalNumbersLink,

        [bool]$PassThru,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [ValidateNotNullOrEmpty()]
[string]$ApiKey
    )
    
    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/settings"

        $ScheduleMeeting = @{
            'host_video'                      = 'HostVideo'
            'participants_video'              = 'ParticipantsVideo'
            'audio_type'                      = 'AudioType'
            'join_before_host'                = 'JoinBeforeHost'
            'force_pmi_jbh_password'          = 'ForcePmiJbhPassword'
            'pstn_password_protected'         = 'PstnPasswordProtected'
            'use_pmi_for_scheduledmeetings'   = 'UsePmiForScheduledMeetings'
            'use_pmi_for_instantmeetings'     = 'UsePmiForInstantMeetings'
        }

        $InMeeting = @{
            'e2e_encryption'                  = 'E2eEncryption'
            'chat'                            = 'Chat' 
            'private_chat'                    = 'PrivateChat' 
            'auto_saving_chat'                = 'AutoSavingChat' 
            'entry_exit_chim'                 = 'EntryExitChim' 
            'record_play_voice'               = 'RecordPlayVoice'
            'file_transfer'                   = 'FileTransfer' 
            'feedback'                        = 'Feedback' 
            'co_host'                         = 'CoHost' 
            'polling'                         = 'Polling' 
            'attendee_on_hold'                = 'AttendeeOnHold' 
            'annotation'                      = 'Annotation' 
            'remote_control'                  = 'RemoteControl' 
            'non_verbal_feedback'             = 'NonVerbalFeedback' 
            'breakout_room'                   = 'BreakoutRoom' 
            'remote_support'                  = 'RemoteSupport' 
            'closed_caption'                  = 'ClosedCaption' 
            'group_hd'                        = 'GroupHd' 
            'virtual_background'              = 'VirtualBackground' 
            'far_end_camera_control '         = 'FarEndCameraControl' 
            'share_dual_camera'               = 'ShareDualCamera' 
            'attention_tracking'              = 'AttentionTracking' 
            'waiting_room'                    = 'WaitingRoom' 
            'allow_live_streaming'            = 'AllowLiveStreaming'
            'workplace_by_facebook'           = 'WorkplaceByFacebook'
            'custom_live_streaming'           = 'CustomLiveStreaming'
            'custom_service_instructions'     = 'CustomServiceInstructions'
        }
        
        $EmailNotification = @{
            'jbh_reminder'                    = 'bhReminder' 
            'cancel_meeting_reminder'         = 'ancelMeetingReminder'
            'alternative_host_reminder'       = 'lternativeHostReminder'
            'schedule_for_reminder'           = 'cheduleForReminder'
        }
        
        $Recording = @{
            'local_recording'                 = 'LocalRecording'
            'cloud_recording'                 = 'CloudRecording'
            'record_speaker_view'             = 'RecordSpeakerView'
            'record_gallery_view'             = 'RecordGalleryView'
            'record_audio_file'               = 'RecordAudioFile'
            'save_chat_text'                  = 'SaveChatText'
            'show_timestamp'                  = 'ShowTimestamp'
            'recording_audio_transcript'      = 'RecordingAudioTranscrip'
            'auto_recording'                  = 'AutoRecording'
            'host_pause_stop_recording '      = 'HostPauseStopRecording'
            'auto_delete_cmr'                 = 'AutoDeleteCmr'
            'auto_delete_cmr_days'            = 'AutoDeleteCmrDay'
        }
        
        $Telephony = @{
            'third_party_audio '              = 'ThirdPartyAudio'
            'audio_conference_info'           = 'AudioConferenceInfo'
            'show_international_numbers_link' = 'ShowInternationalNumbersLink'
        }
        
        $Feature = @{
            'meeting_capacity'                = 'MeetingCapacity'
            'large_meeting'                   = 'LargeMeeting'
            'large_meeting_capacity'          = 'LargeMeetingCapacity'
            'webinar'                         = 'Webinar'
            'webinar_capacity'                = 'WebinarCapacity'
            'zoom_phone'                      = 'ZoomPhone'
        }
        
        $Tsp = @{
            'call_out'                        = 'CallOut'
            'call_out_countries'              = 'CallOutCountries'
            'show_international_numbers_link' = 'ShowInternationalNumbersLink'
        }

        function Remove-NonPSBoundParameters {
            param (
                $Obj,
                $Parameters = $PSBoundParameters
            )

            process {
                $NewObj = @{}
        
                foreach ($Key in $Obj.Keys) {
                    if ($Parameters.ContainsKey($Obj.$Key)){
                        $Newobj.Add($Key, (get-variable $Obj.$Key).value)
                    }
                }
        
                return $NewObj
            }
        }
        
        $ScheduleMeeting = Remove-NonPSBoundParameters($ScheduleMeeting)
        $InMeeting = Remove-NonPSBoundParameters($InMeeting)
        $EmailNotification = Remove-NonPSBoundParameters($EmailNotification)
        $Recording = Remove-NonPSBoundParameters($Recording)
        $Telephony = Remove-NonPSBoundParameters($Telephony)
        $Feature = Remove-NonPSBoundParameters($Feature)
        $Tsp = Remove-NonPSBoundParameters($Tsp)

        $AllObjects = @{
            'schedule_meeting' = $ScheduleMeeting
            'in_meeting' = $InMeeting
            'email_notification' = $EmailNotification
            'recording' = $Recording
            'telephony' = $Telephony
            'feature' = $Feature
            'tsp' = $Tsp
        }

        #Add objects to RequestBody if not empty.
        foreach ($Key in $AllObjects.Keys) {
            if ($AllObjects.$Key -gt 0) {
                $RequestBody.Add($Key, $AllObjects.$Key)
            }
        }

       if ($pscmdlet.ShouldProcess) {
            try {
                Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method Patch
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            } finally {
                if ($PassThru) {
                    if ($_.Exception.Code -ne 404) {
                        Get-ZoomSpecificUser -UserId $UserId
                    }
                }
            }
        }      
    }
}

#Update-ZoomUserSettings -UserId 'jmcevoy@foleyhoag.com' -JoinBeforeHost $True