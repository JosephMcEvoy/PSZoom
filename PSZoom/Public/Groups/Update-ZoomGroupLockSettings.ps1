<#

.SYNOPSIS
Update a group's locked settings. 

.DESCRIPTION
Update a group's locked settings. 
If you lock a setting, the group members will not be able to modify it individually.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.PARAMETER HostVideo 
Start meetings with host video on.
    
.PARAMETER ParticipantVideo 
Start meetings with participant video on.

.PARAMETER AudioType
Determine how participants can join the audio portion of the meeting.

.PARAMETER JoinBeforeHost 
Allow participants to join the meeting before the host arrives

.PARAMETER RequirePasswordForAllMeetings 
Require password from all participants before joining a meeting.

.PARAMETER ForcePmiJbhPassword 
If join before host option is enabled for a personal meeting, then enforce password requirement.

.PARAMETER PstnPasswordProtected 
Generate and send new passwords for newly scheduled or edited meetings.

.PARAMETER MuteUponEntry 
Automatically mute all participants when they join the meeting.

.PARAMETER UpcomingMeetingReminder 
Receive desktop notification for upcoming meetings.

.PARAMETER E2eEncryption 
Require that all meetings are encrypted using AES.

.PARAMETER Chat 
Allow meeting participants to send chat message visible to all participants.

.PARAMETER PrivateChat 
Allow meeting participants to send a private 11 message to another participant.

.PARAMETER AutoSavingChat 
Automatically save all in-meeting chats.

.PARAMETER EntryExitChime 
Play sound when participants join or leave.

.PARAMETER RecordPlayOwnVoice 
When each participant joins by telephone, allow the option to record and play their own voice as entry and exit chimes.

.PARAMETER FileTransfer 
Allow hosts and participants to send files through the in-meeting chat.

.PARAMETER Feedback 
Enable users to provide feedback to Zoom at the end of the meeting.

.PARAMETER PostMeetingFeedback 
Display end-of-meeting experience feedback survey.

.PARAMETER CoHost 
Allow the host to add co-hosts. Co-hosts have the same in-meeting controls as the host.

.PARAMETER Polling 
Add 'Polls' to the meeting controls. This allows the host to survey the attendees.

.PARAMETER AttendeeOnHold 
Allow hosts to temporarily remove an attendee from the meeting.

.PARAMETER ShowMeetingControlToolbar 
Always show meeting controls during a meeting.

.PARAMETER AllowShowZoomWindows 
Show Zoom windows during screen share.

.PARAMETER Annotation 
Allow participants to use annotation tools to add information to shared screens.

.PARAMETER Whiteboard 
Allow participants to share a whiteboard that includes annotation tools.

.PARAMETER RemoteControl 
During screen sharing, allow the person who is sharing to let others control the shared content.

.PARAMETER NonVerbalFeedback 
Allow participants in a meeting can provide nonverbal feedback and express opinions by clicking on icons in the Participants panel.

.PARAMETER BreakoutRoom 
Allow host to split meeting participants into separate, smaller rooms.

.PARAMETER RemoteSupport 
Allow meeting host to provide 11 remote support to another participant.

.PARAMETER ClosedCaption 
Tllow: host to type closed captions or assign a participant/third party device to add closed captions.

.PARAMETER FarEndCameraControl 
Allow another user to take control of the camera during a meeting.

.PARAMETER GroupHd 
Enable higher quality video for host and participants. This will require more bandwidth.

.PARAMETER VirtualBackground 
Enable virtual background.

.PARAMETER AlertGuestJoin 
Allow participants who belong to your account to see that a guest (someone who does not belong to your account) is participating in the meeting/webinar.

.PARAMETER AutoAnswer 
Enable users to see and add contacts to 'auto-answer group' in the contact list on chat. Any call from members of this group will be automatically answered.

.PARAMETER SendingDefaultEmailInvites 
Allow users to invite participants by email only by default.

.PARAMETER UseHtmlFormatEmail 
Allow  HTML formatting instead of plain text for meeting invitations scheduled with the Outlook plugin.

.PARAMETER StereoAudio 
Allow users to select stereo audio during a meeting.

.PARAMETER OriginalAudio 
Allow users to select original sound during a meeting.

.PARAMETER ShowDeviceList 
Show the list of H.323/SIP devices.

.PARAMETER OnlyHostViewDeviceList 
Show the list of H.323/SIP devices only to the host.

.PARAMETER ScreenSharing 
Allow host and participants to share their screen or content during meetings.

.PARAMETER AttentionTracking 
Allow the host to see an indicator in the participant panel if a meeting/webinar attendee does not have Zoom in focus during screen sharing.

.PARAMETER WaitingRoom 
Attendees cannot join a meeting until a host admits them individually from the waiting room.

.PARAMETER ShowBrowserJoinLink 
Allow participants to join a meeting directly from their browser.

.PARAMETER CloudRecordingAvailableReminder 
Notify host when cloud recording is available.

.PARAMETER JbhReminder 
Notify host when participants join the meeting before them.

.PARAMETER CancelMeetingReminder 
Notify host and participants when the meeting is cancelled.

.PARAMETER AlternativeHostReminder 
Notify the alternative host who is set or removed.

.PARAMETER ScheduleForHostReminder 
Notify the host there is a meeting is scheduled, rescheduled, or cancelled.

.PARAMETER LocalRecording 
Allow hosts and participants to record the meeting to a local file.

.PARAMETER CloudRecording 
Allow hosts to record and save the meeting / webinar in the cloud.

.PARAMETER RecordSpeakerView 
Record active speaker with shared screen.

.PARAMETER RecordGalleryView 
When someone is sharing their screen, active speaker will show on the top right corner of the shared screen.

.PARAMETER RecordAudioFile 
Record an audio only file.

.PARAMETER SaveChatText 
Save chat messages from the meeting / webinar.

.PARAMETER ShowTimestamp 
Add a timestamp to the recording.

.PARAMETER RecordingAudioTranscript 
Automatically transcribe the audio of a meeting or webinar for cloud recordings.

.PARAMETER AutoRecording 
Record meetings automatically as they start.

.PARAMETER CloudRecordingDownload 
Allow anyone with a link to the cloud recording to download.

.PARAMETER CloudRecordingDownloadHost 
Allow only the host with a link to the cloud recording to download.

.PARAMETER AccountUserAccessRecording 
Make cloud recordings accessible to account members only.

.PARAMETER HostDeleteCloudRecording 
Allow the host to delete the recordings. If this option is disabled, the recordings cannot be deleted by the host and only admin can delete them.

.PARAMETER ThirdPartyAudio 
Allow users to join the meeting using the existing 3rd party audio configuration.

.PARAMETER AudioConferenceInfo 

.OUTPUTS
No output.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/grouplockedsettings

.EXAMPLE
Update Zoom Group Settings:

$updateParams = @{
    host_video = $True
    chat = $False
    cloud_recording_available_reminder = $True
    cloud_recording = $True
    audio_conference_info = $True
}

Get-ZoomGroups | where-object {$_ -match 'Jedi'} | ZoomGroupLockSettings @updateParams

#>

function Update-ZoomGroupLockSettings  {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group')]
        [string]$GroupId,

        [Alias('host_video')]
        [bool]$HostVideo,

        [Alias('participant_video')]
        [bool]$ParticipantVideo,

        [Alias('audio_type')]
        [bool]$AudioType,

        [Alias('join_before_host')]
        [bool]$JoinBeforeHost,

        [Alias('require_password_for_all_meetings')]
        [bool]$RequirePasswordForAllMeetings,

        [Alias('force_pmi_jbh_password')]
        [bool]$ForcePmiJbhPassword,

        [Alias('pstn_password_protected')]
        [bool]$PstnPasswordProtected,

        [Alias('mute_upon_entry')]
        [bool]$MuteUponEntry,

        [Alias('upcoming_meeting_reminder')]
        [bool]$UpcomingMeetingReminder,
        
        [bool]$Chat,
    
        [Alias('e2e_encryption')]
        [bool]$E2eEncryption,

        [Alias('private_chat')]
        [bool]$PrivateChat,

        [Alias('auto_saving_chat')]
        [bool]$AutoSavingChat,

        [Alias('entry_exit_chime')]
        [string]$EntryExitChime,

        [Alias('record_play_own_voice')]
        [bool]$RecordPlayOwnVoice,

        [Alias('file_transfer')]
        [bool]$FileTransfer,
        
        [bool]$Feedback,

        [Alias('post_meeting_feedback')]
        [bool]$PostMeetingFeedback,

        [Alias('co_host')]
        [bool]$CoHost,
        
        [bool]$Polling,

        [Alias('attendee_on_hold')]
        [bool]$AttendeeOnHold,

        [Alias('show_meeting_control_toolbar')]
        [bool]$ShowMeetingControlToolbar,

        [Alias('allow_show_zoom_windows')]
        [bool]$AllowShowZoomWindows,
        
        [bool]$Annotation,
        
        [bool]$Whiteboard,

        [Alias('remote_control')]
        [bool]$RemoteControl,

        [Alias('non_verbal_feedback')]
        [bool]$NonVerbalFeedback,

        [Alias('breakout_room')]
        [bool]$BreakoutRoom,

        [Alias('remote_support')]
        [bool]$RemoteSupport,

        [Alias('closed_caption')]
        [bool]$ClosedCaption,

        [Alias('far_end_camera_control')]
        [bool]$FarEndCameraControl,

        [Alias('group_hd')]
        [bool]$GroupHd,

        [Alias('virtual_background')]
        [bool]$VirtualBackground,

        [Alias('alert_guest_join')]
        [bool]$AlertGuestJoin,

        [Alias('auto_answer')]
        [bool]$AutoAnswer,

        [Alias('sending_default_email_invites')]
        [bool]$SendingDefaultEmailInvites,

        [Alias('use_html_format_email')]
        [bool]$UseHtmlFormatEmail,

        [Alias('stereo_audio')]
        [bool]$StereoAudio,

        [Alias('original_audio')]
        [bool]$OriginalAudio,

        [Alias('show_device_list')]
        [bool]$ShowDeviceList,

        [Alias('only_host_view_device_list')]
        [bool]$OnlyHostViewDeviceList,

        [Alias('screen_sharing')]
        [bool]$ScreenSharing,

        [Alias('attention_tracking')]
        [bool]$AttentionTracking,

        [Alias('waiting_room')]
        [bool]$WaitingRoom,

        [Alias('show_browser_join_link')]
        [bool]$ShowBrowserJoinLink,

        [Alias('cloud_recording_available_reminder')]
        [bool]$CloudRecordingAvailableReminder,

        [Alias('jbh_reminder')]
        [bool]$JbhReminder,

        [Alias('cancel_meeting_reminder')]
        [bool]$CancelMeetingReminder,

        [Alias('alternative_host_reminder')]
        [bool]$AlternativeHostReminder,

        [Alias('schedule_for_host_reminder')]
        [bool]$ScheduleForHostReminder,

        [Alias('local_recording')]
        [bool]$LocalRecording,

        [Alias('cloud_recording')]
        [bool]$CloudRecording,

        [Alias('record_speaker_view')]
        [bool]$RecordSpeakerView,

        [Alias('record_gallery_view')]
        [bool]$RecordGalleryView,

        [Alias('record_audio_file')]
        [bool]$RecordAudioFile,

        [Alias('save_chat_text')]
        [bool]$SaveChatText,

        [Alias('show_timestamp')]
        [bool]$ShowTimestamp,

        [Alias('recording_audio_transcript')]
        [bool]$RecordingAudioTranscript,

        [Alias('auto_recording')]
        [string]$AutoRecording,

        [Alias('cloud_recording_download')]
        [bool]$CloudRecordingDownload,

        [Alias('cloud_recording_download_host')]
        [bool]$CloudRecordingDownloadHost,

        [Alias('account_user_access_recording')]
        [bool]$AccountUserAccessRecording,

        [Alias('host_delete_cloud_recording')]
        [bool]$HostDeleteCloudRecording,

        [Alias('third_party_audio')]
        [bool]$ThirdPartyAudio,

        [Alias('audio_conference_info')]
        [string]$AudioConferenceInfo,

        [switch]$Passthru
    )

    process {
        $scheduleMeetingParams = @{
            host_video                         = 'HostVideo'
            participant_video                  = 'ParticipantVideo'
            audio_type                         = 'AudioType'
            join_before_host                   = 'JoinBeforeHost'
            require_password_for_all_meetings  = 'RequirePasswordForAllMeetings'
            force_pmi_jbh_password             = 'ForcePmiJbhPassword'
            pstn_password_protected            = 'PstnPasswordProtected'
            mute_upon_entry                    = 'MuteUponEntry'
            upcoming_meeting_reminder          = 'UpcomingMeetingReminder'
        }
        
        $inMeetingParams = @{
            e2e_encryption                     = 'Chat'
            chat                               = 'E2eEncryption'
            private_chat                       = 'PrivateChat'
            auto_saving_chat                   = 'AutoSavingChat'
            entry_exit_chime                   = 'EntryExitChime'
            record_play_own_voice              = 'RecordPlayOwnVoice'
            file_transfer                      = 'FileTransfer'
            feedback                           = 'feedback'
            post_meeting_feedback              = 'PostMeetingFeedback'
            co_host                            = 'CoHost'
            polling                            = 'polling'
            attendee_on_hold                   = 'AttendeeOnHold'
            show_meeting_control_toolbar       = 'ShowMeetingControlToolbar'
            allow_show_zoom_windows            = 'AllowShowZoomWindows'
            annotation                         = 'annotation'
            whiteboard                         = 'whiteboard'
            remote_control                     = 'RemoteControl'
            non_verbal_feedback                = 'NonVerbalFeedback'
            breakout_room                      = 'BreakoutRoom'
            remote_support                     = 'RemoteSupport'
            closed_caption                     = 'ClosedCaption'
            far_end_camera_control             = 'FarEndCameraControl'
            group_hd                           = 'GroupHd'
            virtual_background                 = 'VirtualBackground'
            alert_guest_join                   = 'AlertGuestJoin'
            auto_answer                        = 'AutoAnswer'
            sending_default_email_invites      = 'SendingDefaultEmailInvites'
            use_html_format_email              = 'UseHtmlFormatEmail'
            stereo_audio                       = 'StereoAudio'
            original_audio                     = 'OriginalAudio'
            show_device_list                   = 'ShowDeviceList'
            only_host_view_device_list         = 'OnlyHostViewDeviceList'
            screen_sharing                     = 'ScreenSharing'
            attention_tracking                 = 'AttentionTracking'
            waiting_room                       = 'WaitingRoom'
            show_browser_join_link             = 'ShowBrowserJoinLink'
        }
        
        $emailNotificationParams = @{
            cloud_recording_available_reminder = 'CloudRecordingAvailableReminder'
            jbh_reminder                       = 'JbhReminder'
            cancel_meeting_reminder            = 'CancelMeetingReminder'
            alternative_host_reminder          = 'AlternativeHostReminder'
            schedule_for_host_reminder         = 'ScheduleForHostReminder'
        }
        
        $recordingParams = @{
            local_recording                    = 'LocalRecording'
            cloud_recording                    = 'CloudRecording'
            record_speaker_view                = 'RecordSpeakerView'
            record_gallery_view                = 'RecordGalleryView'
            record_audio_file                  = 'RecordAudioFile'
            save_chat_text                     = 'SaveChatText'
            show_timestamp                     = 'ShowTimestamp'
            recording_audio_transcript         = 'RecordingAudioTranscript'
            auto_recording                     = 'AutoRecording'
            cloud_recording_download           = 'CloudRecordingDownload'
            cloud_recording_download_host      = 'CloudRecordingDownloadHost'
            account_user_access_recording      = 'AccountUserAccessRecording'
            host_delete_cloud_recording        = 'HostDeleteCloudRecording'
        }
        
        $telephonyParams = @{
            third_party_audio                  = 'ThirdPartyAudio'
            audio_conference_info              = 'AudioConferenceInfo'
        }

        function Remove-NonPsBoundParameters {
            <#
            This function looks at the values of the keys passed to it then determines if they were 
            passed in the process scope. Only the parameters that were passed that match the value names are 
            outputted.
            #>
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

        $allObjects = @{ 
            'schedule_meeting'   = Remove-NonPsBoundParameters($scheduleMeetingParams)
            'in_meeting'         = Remove-NonPsBoundParameters($inMeetingParams)
            'email_notification' = Remove-NonPsBoundParameters($emailNotificationParams)
            'recording'          = Remove-NonPsBoundParameters($recordingParams)
            'telephony'          = Remove-NonPsBoundParameters($telephonyParams)
        }

        $requestBody = @{}
        
        foreach ($Key in $allObjects.Keys) {
            if ($allObjects.$Key.Count -gt 0) {
                $requestBody.Add($Key, $allObjects.$Key)
            }
        }
        
        $requestBody = $requestBody | ConvertTo-Json

        foreach ($id in $GroupId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$GroupId/lock_settings"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

            if (-not $Passthru) {
                Write-Output $response
            }
        }
    
        if ($Passthru) {
            Write-Output $GroupId
        }
        
    }
}