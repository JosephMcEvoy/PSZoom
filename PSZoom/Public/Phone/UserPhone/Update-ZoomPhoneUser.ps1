<#

.SYNOPSIS
Update a specific user Zoom Phone account.
                    
.PARAMETER UserId
Unique number used to locate Zoom Phone User account.

.PARAMETER EmergencyAddressID
The emergency address ID.

.PARAMETER ExtensionNumber
The extension number of the user. The number must be complete (i.e. site number + short extension).

.PARAMETER SiteId
The unique identifier of the site where the user should be moved or assigned.

.PARAMETER TemplateID
The settings template ID. If the site_id field is set, look for the template site with the value of the site_id field. The template ID has precedence and the policy will be ignored even if the policy field is set.

.PARAMETER PolicyVmAllowDelete
This field allows the user to delete his own voicemail.

.PARAMETER PolicyVmAllowDownload
This field allows the user to download his own voicemail.

.PARAMETER PolicyVmAllowTranscription
Whether to allow voicemail transcription.

.PARAMETER PolicyVmAllowVideomail
Whether to allow users to access, share, download or delete the videomail.

.PARAMETER PolicyVmEnable
Whether the current extension can access, receive, or share voicemail.

.PARAMETER PolicyVmAccessAllowUserId
The Zoom user ID to share the voicemail access permissions with.

.PARAMETER PolicyVmAccessAllowDelete
Whether the user has delete permissions. The default is false.

.PARAMETER PolicyVmAccessAllowDownload
Whether the user has download permissions. The default is false.

.PARAMETER PolicyVmAccessAllowSharing
Whether the user has permission to share. The default is false.

.PARAMETER PolicyAllowMobileCalling
Whether to allow Calling and SMS/MMS functions on Mobile.

.PARAMETER PolicyEnableMobile
Whether to allow user to use Zoom Phone on mobile clients (iOS, iPad OS and Android).

.PARAMETER PolicyAllowMusicOnHoldCustomization
Whether to allow the user to customize allow music on hold.

.PARAMETER PolicyAllowMessageGreetingCustomization
Whether to allow the user to customize voicemail and message greeting.

.PARAMETER PolicyEnableAudioLibrary
Whether to allow users to change their own audio library.

.PARAMETER PolicyResetAudioLibrary
Whether the user's personal audio library reset option will use the phone site's settings.

.PARAMETER PolicyEnableVmTranscript
Whether to allow the user to access transcriptions of voicemails`.

.PARAMETER PolicyResetVmTranscript
Whether the user's voicemail transcription reset option will use the phone site's settings.

.PARAMETER PolicyVmEmailIncludeAudioFile
Whether to include voicemail file.

.PARAMETER PolicyVmEmailIncludeAudioTranscript
Whether to include voicemail transcription.

.PARAMETER PolicyVmEnableEmail
If enabled, user will receive email notifications when there is a new voicemail from users, call queues, auto receptionists or shared line groups.

.PARAMETER PolicyVmResetEmail
Whether the user's voicemail notification by email reset option will use the phone site's settings.

.PARAMETER PolicyVmEnableSharedEmail
If enabled, the user will receive email notification when there is a new shared voicemail.

.PARAMETER PolicyVmResetSharedEmail
Whether the user's share voicemail notification by email reset option will use the phone site's settings.

.PARAMETER PolicyVmEnableCheckVmOverPhone
If enabled, user can check voicemails over phone using a PIN code.

.PARAMETER PolicyVmResetCheckVmOverPhone
Whether the user's check voicemail over phone reset option will use the phone site's settings.

.PARAMETER PolicyVmEnableIntercom
If enabled, user can use audio intercom.

.PARAMETER PolicyVmResetIntercom
Whether the user's audio intercom reset option will use the phone site's settings.

.PARAMETER PolicyE2eEncryptionEnable
Whether to allow users to switch their calls to End-to-End Encryption. If users have the Automatic Call Recording turned on, they will not be able to use the End-to-End Encryption.

.PARAMETER PolicyE2eEncryptionReset
Whether the current settings will use the phone account's settings (applicable if the current settings are using the new policy framework).

.PARAMETER PolicyInternationalCallingEnable
Whether the current extension can make international calls outside of their calling plan.

.PARAMETER PolicyEnableAdHocCallRecordingBeepTone
Whether to play a side tone beep for recorded users while recording. Only displayed when ad hoc call recording policy uses the new framework.

.PARAMETER PolicyAdHocCallRecordingBeepToneVolume
The volume of the side tone beep. It displays only when enable is set to true.
Allowed: 0┃20┃40┃60┃80┃100

.PARAMETER PolicyAdHocCallRecordingBeepToneInterval
The beep time interval in seconds. It displays only when enable is true.
Allowed: 5┃10┃15┃20┃25┃30┃60┃120

.PARAMETER PolicyAdHocCallRecordingBeepToneMember
The beep sides. It displays only when enable is true.
Allowed: allMember┃recordingSide

.PARAMETER PolicyEnableAdHocCallRecording
Whether the current extension can record and save calls to the cloud.

.PARAMETER PolicyAdHocCallRecordingStartPrompt
Whether a prompt plays to call participants when the recording has started.

.PARAMETER PolicyAdHocCallRecordingTranscript
Whether call recording transcription is enabled.

.PARAMETER PolicyResetAdHocCallRecording
Whether the user's ad hoc recording reset option will use the phone site's settings.

.PARAMETER PolicyEnableAutoCallRecordingBeepTone
Whether to play a side tone beep for recorded users while recording. Only displayed when auto call recording policy uses the new framework.

.PARAMETER PolicyAutoCallRecordingBeepToneVolume
The volume of the side tone beep. It displays only when enable is set to true.
Allowed: 0┃20┃40┃60┃80┃100

.PARAMETER PolicyAutoCallRecordingBeepToneInterval
The beep time interval in seconds. It displays only when enable is true.
Allowed: 5┃10┃15┃20┃25┃30┃60┃120

.PARAMETER PolicyAutoCallRecordingBeepToneMember
The beep sides. It displays only when enable is true.
Allowed: allMember┃recordingSide

.PARAMETER PolicyEnableAutoCallRecording
Whether automatic call recording is enabled.

.PARAMETER PolicyAutoCallRecordingAllowStopResumeRecording
Whether the stop of and resuming of automatic call recording is enabled.

.PARAMETER PolicyAutoCallRecordingDisconnectOnRecordingFailure
Whether a call disconnects when there is an issue with automatic call recording and the call cannot reconnect after five seconds. This does not include emergency calls.

.PARAMETER PolicyAutoCallRecordingType
The type of calls automatically recorded:
Allowed:  inbound|outbound|both

.PARAMETER PolicyAutoCallRecordingExplicitConsent
Whether press 1 to provide recording consent is enabled.

.PARAMETER PolicyAutoCallRecordingStartPrompt
Whether a prompt plays to call participants when the recording has started.

.PARAMETER PolicyAutoCallRecordingTranscription
Whether call recording transcription is enabled.

.PARAMETER PolicyResetAutoCallRecording
Whether the user's automatic call recording reset option will use the phone site's settings.

.PARAMETER PolicyCallOverflowEnable
Whether to allow user to forward calls to other numbers.

.PARAMETER PolicyCallOverflowReset
Whether the current settings will use the phone site's settings (applicable if the current settings are using the new policy framework).

.PARAMETER PolicyCallOverflowType
1 - Low restriction (external numbers not allowed) 
2 - Medium restriction (external numbers and external contacts not allowed) 
3 - High restriction (external numbers, external contacts and internal extensions without inbound automatic call recording not allowed) 
4 - No restriction
Allowed: 1┃2┃3┃4

.PARAMETER PolicyCallParkEnable
Whether to allow calls placed on hold to be resumed from another location using a retrieval code.

.PARAMETER PolicyCallParkCallNotPickedUpAction
The action when a parked call is not picked up. 100-Ring back to parker, 0-Forward to voicemail of the parker, 9-Disconnect, 50-Forward to another extension.

.PARAMETER PolicyCallParkCallExpirationPeriod
A time limit for parked calls, unit minutes. After the expiration period ends, the retrieval code is no longer valid and a new code will be generated.
Allowed: 1┃2┃3┃4┃5┃6┃7┃8┃9┃10┃15┃20┃25┃30┃35┃40┃45┃50┃55┃60

.PARAMETER PolicyCallParkForwardToExtensionId
The extension ID.

.PARAMETER PolicyCallTransferringEnable
Whether to allow the user to warm or blind transfer their calls. This does not apply to warm transfer on IP Phones except for Yealink.

.PARAMETER PolicyCallTransferringReset
Whether the current settings will use the phone site's settings (applicable if the current settings are using the new policy framework).

.PARAMETER PolicyCallTransferringType
1-No restriction. 
2-Medium restriction (external numbers and external contacts not allowed). 
3-High restriction (external numbers, unrecorded external contacts, and internal extensions without inbound automatic recording not allowed). 
4-Low restriction (external numbers not allowed).
Allowed: 1┃2┃3┃4

.PARAMETER PolicyEmergencyAddressEnable
Whether to allow the current extension to manage its own emergency addresses.

.PARAMETER PolicyEmergencyAddressPromptDefault
Whether to prompt the user to set or confirm a default address.

.PARAMETER PolicyCallHandlingForwardingToOtherUsersEnable

.PARAMETER PolicyCallHandlingForwardingToOtherUsersReset
Whether the current settings will use the phone site's settings (applicable if the current settings are using the new policy framework).

.PARAMETER PolicyCallHandlingForwardingToOtherUsersType
1 - Low restriction (external numbers not allowed) 
2 - Medium restriction (external numbers and external contacts not allowed) 
3 - High restriction (external numbers, external contacts and internal extensions without inbound automatic call recording not allowed) 
4 - No restriction
Allowed: 1┃2┃3┃4

.PARAMETER PolicyHandOffToRoomEnable
Whether to allow users to send a call to a Zoom Room.

.PARAMETER PolicyMobileSwitchToCarrierEnable
Whether to allow the user to switch from a Zoom Phone to their native carrier.

.PARAMETER PolicySelectOutboundCallerIdEnable
Whether to allow the current extension to change the outbound caller ID when placing calls.

.PARAMETER PolicyMobileSwitchToCarrierAllowHide
Whether to allow the current extension to hide outbound caller id.

.PARAMETER PolicySmsEnable
Whether the user can send and receive messages.

.PARAMETER PolicySmsInternational
Whether the user can send and receive international messages.

.PARAMETER PolicySmsInternationalCountries
The country which can send and receive international messages. The country iso code.

.PARAMETER PolicyDelegationEnable
Whether the user can use call delegation.

.PARAMETER PolicyElevateToMeetingEnable
Whether the user can elevate their phone calls to a meeting.

.PARAMETER PolicyEmergencyCallsToPsapEnable
When disabled, emergency calls placed by the user will not be delivered to the Public Safety Answering Point(PSAP), but still will be delivered to the Internal Safety Response Team based on the settings.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Assign new extension number
Update-ZoomPhoneUser -UserId askywakler@thejedi.com -ExtensionNumber 011234567

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateUserProfile

#>

function Update-ZoomPhoneUser {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'Emails', 'EmailAddress', 'EmailAddresses', 'Id', 'ids', 'user_id', 'user', 'users', 'userids')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('emergency_address')]
        [string]$EmergencyAddressID,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('extension_number')]
        [int64]$ExtensionNumber,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('site_id')]
        [string]$SiteId,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('template_id')]
        [string]$TemplateID,

        [Parameter()]
        [bool]$PolicyVmAllowDelete,

        [Parameter()]
        [bool]$PolicyVmAllowDownload,

        [Parameter()]
        [bool]$PolicyVmAllowTranscription,

        [Parameter()]
        [bool]$PolicyVmAllowVideomail,

        [Parameter()]
        [bool]$PolicyVmEnable,

        [Parameter()]
        [string]$PolicyVmAccessAllowUserId,

        [Parameter()]
        [ValidateScript({ $PolicyVmAccessAllowUserId })]
        [bool]$PolicyVmAccessAllowDelete,

        [Parameter()]
        [ValidateScript({ $PolicyVmAccessAllowUserId })]
        [bool]$PolicyVmAccessAllowDownload,

        [Parameter()]
        [ValidateScript({ $PolicyVmAccessAllowUserId })]
        [bool]$PolicyVmAccessAllowSharing,

        [Parameter()]
        [bool]$PolicyAllowMobileCalling,

        [Parameter()]
        [bool]$PolicyEnableMobile,

        [Parameter()]
        [bool]$PolicyAllowMusicOnHoldCustomization,

        [Parameter()]
        [bool]$PolicyAllowMessageGreetingCustomization,

        [Parameter()]
        [bool]$PolicyEnableAudioLibrary,

        [Parameter()]
        [bool]$PolicyResetAudioLibrary,

        [Parameter()]
        [bool]$PolicyEnableVmTranscript,

        [Parameter()]
        [bool]$PolicyResetVmTranscript,

        [Parameter()]
        [bool]$PolicyVmEmailIncludeAudioFile,

        [Parameter()]
        [bool]$PolicyVmEmailIncludeAudioTranscript,

        [Parameter()]
        [bool]$PolicyVmEnableEmail,

        [Parameter()]
        [bool]$PolicyVmResetEmail,

        [Parameter()]
        [bool]$PolicyVmEnableSharedEmail,

        [Parameter()]
        [bool]$PolicyVmResetSharedEmail,

        [Parameter()]
        [bool]$PolicyVmEnableCheckVmOverPhone,

        [Parameter()]
        [bool]$PolicyVmResetCheckVmOverPhone,
        
        [Parameter()]
        [bool]$PolicyVmEnableIntercom,

        [Parameter()]
        [bool]$PolicyVmResetIntercom,

        [Parameter()]
        [bool]$PolicyE2eEncryptionEnable,

        [Parameter()]
        [bool]$PolicyE2eEncryptionReset,

        [Parameter()]
        [bool]$PolicyInternationalCallingEnable,

        [Parameter()]
        [bool]$PolicyEnableAdHocCallRecordingBeepTone,

        [Parameter()]
        [ValidateSet(0,20,40,60,80,100)]
        [int]$PolicyAdHocCallRecordingBeepToneVolume,

        [Parameter()]
        [ValidateSet(5,10,15,20,25,30,60,120)]
        [int]$PolicyAdHocCallRecordingBeepToneInterval,

        [Parameter()]
        [ValidateSet('allMember','recordingSide')]
        [string]$PolicyAdHocCallRecordingBeepToneMember,

        [Parameter()]
        [bool]$PolicyEnableAdHocCallRecording,

        [Parameter()]
        [bool]$PolicyAdHocCallRecordingStartPrompt,

        [Parameter()]
        [bool]$PolicyAdHocCallRecordingTranscript,

        [Parameter()]
        [bool]$PolicyResetAdHocCallRecording,

        [Parameter()]
        [bool]$PolicyEnableAutoCallRecordingBeepTone,

        [Parameter()]
        [ValidateSet(0,20,40,60,80,100)]
        [int]$PolicyAutoCallRecordingBeepToneVolume,

        [Parameter()]
        [ValidateSet(5,10,15,20,25,30,60,120)]
        [int]$PolicyAutoCallRecordingBeepToneInterval,

        [Parameter()]
        [ValidateSet('allMember','recordingSide')]
        [string]$PolicyAutoCallRecordingBeepToneMember,

        [Parameter()]
        [bool]$PolicyEnableAutoCallRecording,

        [Parameter()]
        [bool]$PolicyAutoCallRecordingAllowStopResumeRecording,

        [Parameter()]
        [bool]$PolicyAutoCallRecordingDisconnectOnRecordingFailure,

        [Parameter()]
        [ValidateSet('inbound','outbound','both')]
        [string]$PolicyAutoCallRecordingType,

        [Parameter()]
        [bool]$PolicyAutoCallRecordingExplicitConsent,

        [Parameter()]
        [bool]$PolicyAutoCallRecordingStartPrompt,

        [Parameter()]
        [bool]$PolicyAutoCallRecordingTranscription,

        [Parameter()]
        [bool]$PolicyResetAutoCallRecording,

        [Parameter()]
        [bool]$PolicyCallOverflowEnable,

        [Parameter()]
        [bool]$PolicyCallOverflowReset,

        [Parameter()]
        [ValidateSet(1,2,3,4)]
        [int]$PolicyCallOverflowType,

        [Parameter()]
        [bool]$PolicyCallParkEnable,

        [Parameter()]
        [ValidateSet(10,0,9,50)]
        [int]$PolicyCallParkCallNotPickedUpAction,

        [Parameter()]
        [ValidateSet(1,2,3,4,5,6,7,8,9,10,15,20,25,30,35,40,45,50,55,60)]
        [int]$PolicyCallParkCallExpirationPeriod,

        [Parameter()]
        [Int64]$PolicyCallParkForwardToExtensionId,

        [Parameter()]
        [bool]$PolicyCallTransferringEnable,

        [Parameter()]
        [bool]$PolicyCallTransferringReset,

        [Parameter()]
        [ValidateSet(1,2,3,4)]
        [int]$PolicyCallTransferringType,

        [Parameter()]
        [bool]$PolicyEmergencyAddressEnable,

        [Parameter()]
        [bool]$PolicyEmergencyAddressPromptDefault,

        [Parameter()]
        [bool]$PolicyCallHandlingForwardingToOtherUsersEnable,

        [Parameter()]
        [bool]$PolicyCallHandlingForwardingToOtherUsersReset,
        
        [Parameter()]
        [ValidateSet(1,2,3,4)]
        [int]$PolicyCallHandlingForwardingToOtherUsersType,

        [Parameter()]
        [bool]$PolicyHandOffToRoomEnable,
        
        [Parameter()]
        [bool]$PolicyMobileSwitchToCarrierEnable,
        
        [Parameter()]
        [bool]$PolicySelectOutboundCallerIdEnable,
        
        [Parameter()]
        [bool]$PolicyMobileSwitchToCarrierAllowHide,
        
        [Parameter()]
        [bool]$PolicySmsEnable,
        
        [Parameter()]
        [bool]$PolicySmsInternational,
        
        [Parameter()]
        [array]$PolicySmsInternationalCountries,
        
        [Parameter()]
        [bool]$PolicyDelegationEnable,
        
        [Parameter()]
        [bool]$PolicyElevateToMeetingEnable,

        [Parameter()]
        [bool]$PolicyEmergencyCallsToPsapEnable,

        [switch]$PassThru
    )
    
    process {
        foreach ($user in $UserId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user"

                #region ad_hoc_play_recording_beep_tone
                $ad_hoc_play_recording_beep_tone = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyEnableAdHocCallRecordingBeepTone')) {
                    $ad_hoc_play_recording_beep_tone.Add("enable", $PolicyEnableAdHocCallRecordingBeepTone)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAdHocCallRecordingBeepToneVolume')) {
                    $ad_hoc_play_recording_beep_tone.Add("play_beep_volume", $PolicyAdHocCallRecordingBeepToneVolume)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAdHocCallRecordingBeepToneInterval')) {
                    $ad_hoc_play_recording_beep_tone.Add("play_beep_time_interval", $PolicyAdHocCallRecordingBeepToneInterval)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAdHocCallRecordingBeepToneMember')) {
                    $ad_hoc_play_recording_beep_tone.Add("play_beep_member", $PolicyAdHocCallRecordingBeepToneMember)
                }

                #endregion ad_hoc_play_recording_beep_tone

                #region ad_hoc_call_recording
                $ad_hoc_call_recording = @{ }
                if ($PSBoundParameters.ContainsKey('PolicyEnableAdHocCallRecording')) {
                    $ad_hoc_call_recording.Add("enable", $PolicyEnableAdHocCallRecording)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAdHocCallRecordingStartPrompt')) {
                    $ad_hoc_call_recording.Add("recording_start_prompt", $PolicyAdHocCallRecordingStartPrompt)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAdHocCallRecordingTranscript')) {
                    $ad_hoc_call_recording.Add("recording_transcription", $PolicyAdHocCallRecordingTranscript)
                }

                if ($PSBoundParameters.ContainsKey('PolicyResetAdHocCallRecording')) {
                    $ad_hoc_call_recording.Add("reset", $PolicyResetAdHocCallRecording)
                }

                if ($ad_hoc_play_recording_beep_tone.Count -ne 0) {
                    $ad_hoc_call_recording.Add("play_recording_beep_tone", $ad_hoc_play_recording_beep_tone)
                }

                #endregion ad_hoc_call_recording

                #region auto_play_recording_beep_tone
                $auto_play_recording_beep_tone = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyEnableAutoCallRecordingBeepTone')) {
                    $auto_play_recording_beep_tone.Add("enable", $PolicyEnableAutoCallRecordingBeepTone)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingBeepToneVolume')) {
                    $auto_play_recording_beep_tone.Add("play_beep_volume", $PolicyAutoCallRecordingBeepToneVolume)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingBeepToneInterval')) {
                    $auto_play_recording_beep_tone.Add("play_beep_time_interval", $PolicyAutoCallRecordingBeepToneInterval)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingBeepToneMember')) {
                    $auto_play_recording_beep_tone.Add("play_beep_member", $PolicyAutoCallRecordingBeepToneMember)
                }

                #endregion auto_play_recording_beep_tone

            #region auto_call_recording
                $auto_call_recording = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyEnableAutoCallRecording')) {
                    $auto_call_recording.Add("enable", $PolicyEnableAutoCallRecording)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingAllowStopResumeRecording')) {
                    $auto_call_recording.Add("allow_stop_resume_recording", $PolicyAutoCallRecordingAllowStopResumeRecording)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingDisconnectOnRecordingFailure')) {
                    $auto_call_recording.Add("disconnect_on_recording_failure", $PolicyAutoCallRecordingDisconnectOnRecordingFailure)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingType')) {
                    $auto_call_recording.Add("recording_calls", $PolicyAutoCallRecordingType)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingExplicitConsent')) {
                    $auto_call_recording.Add("recording_explicit_consent", $PolicyAutoCallRecordingExplicitConsent)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingStartPrompt')) {
                    $auto_call_recording.Add("recording_start_prompt", $PolicyAutoCallRecordingStartPrompt)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAutoCallRecordingTranscription')) {
                    $auto_call_recording.Add("recording_transcription", $PolicyAutoCallRecordingTranscription)
                }

                if ($PSBoundParameters.ContainsKey('PolicyResetAutoCallRecording')) {
                    $auto_call_recording.Add("reset", $PolicyResetAutoCallRecording)
                }  

                if ($auto_play_recording_beep_tone.Count -ne 0) {
                    $auto_call_recording.Add("play_recording_beep_tone", $auto_play_recording_beep_tone)
                }

            #endregion auto_call_recording

            #region call_overflow
                $call_overflow = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyCallOverflowEnable')) {
                    $call_overflow.Add("enable", $PolicyCallOverflowEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallOverflowReset')) {
                    $call_overflow.Add("reset", $PolicyCallOverflowReset)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallOverflowType')) {
                    $call_overflow.Add("call_overflow_type", $PolicyCallOverflowType)
                }

            #endregion call_overflow


            #region call_park
                $call_park = @{ }
                if ($PSBoundParameters.ContainsKey('PolicyCallParkEnable')) {
                    $call_park.Add("enable", $PolicyCallParkEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallParkCallNotPickedUpAction')) {
                    $call_park.Add("call_not_picked_up_action", $PolicyCallParkCallNotPickedUpAction)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallParkCallExpirationPeriod')) {
                    $call_park.Add("expiration_period", $PolicyCallParkCallExpirationPeriod)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallParkForwardToExtensionId')) {
                    $call_park.Add("forward_to_extension_id", [string]$PolicyCallParkForwardToExtensionId)
                }

            #endregion call_overflow


            #region call_transferring
                $call_transferring = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyCallTransferringEnable')) {
                    $call_transferring.Add("enable", $PolicyCallTransferringEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallTransferringReset')) {
                    $call_transferring.Add("reset", $PolicyCallTransferringReset)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallTransferringType')) {
                    $call_transferring.Add("call_transferring_type", $PolicyCallTransferringType)
                }

            #endregion call_transferring


            #region emergency_address_management
                $emergency_address_management = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyEmergencyAddressEnable')) {
                    $emergency_address_management.Add("enable", $PolicyEmergencyAddressEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyEmergencyAddressPromptDefault')) {
                    $emergency_address_management.Add("prompt_default_address", $PolicyEmergencyAddressPromptDefault)
                }

            #endregion emergency_address_management


            #region call_handling_forwarding_to_other_users
                $call_handling_forwarding_to_other_users = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyCallHandlingForwardingToOtherUsersEnable')) {
                    $call_handling_forwarding_to_other_users.Add("enable", $PolicyCallHandlingForwardingToOtherUsersEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallHandlingForwardingToOtherUsersReset')) {
                    $call_handling_forwarding_to_other_users.Add("reset", $PolicyCallHandlingForwardingToOtherUsersReset)
                }

                if ($PSBoundParameters.ContainsKey('PolicyCallHandlingForwardingToOtherUsersType')) {
                    $call_handling_forwarding_to_other_users.Add("call_forwarding_type", $PolicyCallHandlingForwardingToOtherUsersType)
                }

            #endregion call_handling_forwarding_to_other_users


            #region hand_off_to_room
                $hand_off_to_room = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyHandOffToRoomEnable')) {
                    $hand_off_to_room.Add("enable", $PolicyHandOffToRoomEnable)
                }

            #endregion hand_off_to_room


            #region mobile_switch_to_carrier
                $mobile_switch_to_carrier = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyMobileSwitchToCarrierEnable')) {
                    $mobile_switch_to_carrier.Add("enable", $PolicyMobileSwitchToCarrierEnable)
                }

            #endregion mobile_switch_to_carrier


            #region mobile_switch_to_carrier
                $select_outbound_caller_id = @{ }

                if ($PSBoundParameters.ContainsKey('PolicySelectOutboundCallerIdEnable')) {
                    $select_outbound_caller_id.Add("enable", $PolicySelectOutboundCallerIdEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyMobileSwitchToCarrierAllowHide')) {
                    $select_outbound_caller_id.Add("allow_hide_outbound_caller_id", $PolicyMobileSwitchToCarrierAllowHide)
                }

            #endregion mobile_switch_to_carrier


            #region sms
                $sms = @{ }

                if ($PSBoundParameters.ContainsKey('PolicySmsEnable')) {
                    $sms.Add("enable", $PolicySmsEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicySmsInternational')) {
                    $sms.Add("international_sms", $PolicySmsInternational)
                }

                if ($PSBoundParameters.ContainsKey('PolicySmsInternationalCountries')) {
                    $sms.Add("international_sms_countries", $PolicySmsInternationalCountries)
                }

            #endregion sms


            #region Voicemail
                $voicemail = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyVmAllowDelete')) {
                    $voicemail.Add("allow_delete", $PolicyVmAllowDelete)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmAllowDownload')) {
                    $voicemail.Add("allow_download", $PolicyVmAllowDownload)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmAllowTranscription')) {
                    $voicemail.Add("allow_transcription", $PolicyVmAllowTranscription)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmAllowVideomail')) {
                    $voicemail.Add("allow_videomail", $PolicyVmAllowVideomail)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmEnable')) {
                    $voicemail.Add("enable", $PolicyVmEnable)
                }

            #endregion Voicemail


            #region voicemail_access_members
                $voicemail_access_members = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyVmAccessAllowUserId')) {
                    $voicemail_access_members.Add("access_user_id", $PolicyVmAccessAllowUserId)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmAccessAllowDelete')) {
                    $voicemail_access_members.Add("allow_delete", $PolicyVmAccessAllowDelete)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmAccessAllowDownload')) {
                    $voicemail_access_members.Add("allow_download", $PolicyVmAccessAllowDownload)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmAccessAllowSharing')) {
                    $voicemail_access_members.Add("allow_sharing", $PolicyVmAccessAllowSharing)
                }

            #endregion voicemail_access_members


            #region zoom_phone_on_mobile
                $zoom_phone_on_mobile = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyAllowMobileCalling')) {
                    $zoom_phone_on_mobile.Add("allow_calling_sms_mms", $PolicyAllowMobileCalling)
                }

                if ($PSBoundParameters.ContainsKey('PolicyEnableMobile')) {
                    $zoom_phone_on_mobile.Add("enable", $PolicyEnableMobile)
                }

            #endregion zoom_phone_on_mobile


            #region personal_audio_library
                $personal_audio_library = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyAllowMusicOnHoldCustomization')) {
                    $personal_audio_library.Add("allow_music_on_hold_customization", $PolicyAllowMusicOnHoldCustomization)
                }

                if ($PSBoundParameters.ContainsKey('PolicyAllowMessageGreetingCustomization')) {
                    $personal_audio_library.Add("allow_voicemail_and_message_greeting_customization", $PolicyAllowMessageGreetingCustomization)
                }

                if ($PSBoundParameters.ContainsKey('PolicyEnableAudioLibrary')) {
                    $personal_audio_library.Add("enable", $PolicyEnableAudioLibrary)
                }

                if ($PSBoundParameters.ContainsKey('PolicyResetAudioLibrary')) {
                    $personal_audio_library.Add("reset", $PolicyResetAudioLibrary)
                }

            #endregion personal_audio_library


            #region voicemail_transcription
                $voicemail_transcription = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyEnableVmTranscript')) {
                    $voicemail_transcription.Add("enable", $PolicyEnableVmTranscript)
                }

                if ($PSBoundParameters.ContainsKey('PolicyResetVmTranscript')) {
                    $voicemail_transcription.Add("reset", $PolicyResetVmTranscript)
                }

            #endregion voicemail_transcription


            #region voicemail_notification_by_email
                $voicemail_notification_by_email = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyVmEmailIncludeAudioFile')) {
                    $voicemail_notification_by_email.Add("include_voicemail_file", $PolicyVmEmailIncludeAudioFile)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmEmailIncludeAudioTranscript')) {
                    $voicemail_notification_by_email.Add("include_voicemail_transcription", $PolicyVmEmailIncludeAudioTranscript)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmEnableEmail')) {
                    $voicemail_notification_by_email.Add("enable", $PolicyVmEnableEmail)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmResetEmail')) {
                    $voicemail_notification_by_email.Add("reset", $PolicyVmResetEmail)
                }

            #endregion voicemail_notification_by_email


            #region shared_voicemail_notification_by_email
                $shared_voicemail_notification_by_email = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyVmEnableSharedEmail')) {
                    $shared_voicemail_notification_by_email.Add("enable", $PolicyVmEnableSharedEmail)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmResetSharedEmail')) {
                    $shared_voicemail_notification_by_email.Add("reset", $PolicyVmResetSharedEmail)
                }

            #endregion shared_voicemail_notification_by_email


            #region check_voicemails_over_phone
                $check_voicemails_over_phone = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyVmEnableCheckVmOverPhone')) {
                    $check_voicemails_over_phone.Add("enable", $PolicyVmEnableCheckVmOverPhone)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmResetCheckVmOverPhone')) {
                    $check_voicemails_over_phone.Add("reset", $PolicyVmResetCheckVmOverPhone)
                }

            #endregion check_voicemails_over_phone


            #region audio_intercom
                $audio_intercom = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyVmEnableIntercom')) {
                    $audio_intercom.Add("enable", $PolicyVmEnableIntercom)
                }

                if ($PSBoundParameters.ContainsKey('PolicyVmResetIntercom')) {
                    $audio_intercom.Add("reset", $PolicyVmResetIntercom)
                }

            #endregion audio_intercom


            #region e2e_encryption
                $e2e_encryption = @{ }

                if ($PSBoundParameters.ContainsKey('PolicyE2eEncryptionEnable')) {
                    $e2e_encryption.Add("enable", $PolicyE2eEncryptionEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyE2eEncryptionReset')) {
                    $e2e_encryption.Add("reset", $PolicyE2eEncryptionReset)
                }

            #endregion e2e_encryption


            #region policy
                $policy = @{ }

                if ($ad_hoc_call_recording.Count -ne 0) {
                    $policy.Add("ad_hoc_call_recording", $ad_hoc_call_recording)
                }

                if ($auto_call_recording.Count -ne 0) {
                    $policy.Add("auto_call_recording", $auto_call_recording)
                }

                if ($call_overflow.Count -ne 0) {
                    $policy.Add("call_overflow", $call_overflow)
                }
                
                if ($call_park.Count -ne 0) {
                    $policy.Add("call_park", $call_park)
                }

                if ($call_transferring.Count -ne 0) {
                    $policy.Add("call_transferring", $call_transferring)
                }

                if ($PSBoundParameters.ContainsKey('PolicyDelegationEnable')) {
                    $policy.Add("delegation", $PolicyDelegationEnable)
                }

                if ($PSBoundParameters.ContainsKey('PolicyElevateToMeetingEnable')) {
                    $policy.Add("elevate_to_meeting", $PolicyElevateToMeetingEnable)
                }

                if ($emergency_address_management.Count -ne 0) {
                    $policy.Add("emergency_address_management", $emergency_address_management)
                }

                if ($PSBoundParameters.ContainsKey('PolicyEmergencyCallsToPsapEnable')) {
                    $policy.Add("emergency_calls_to_psap", $PolicyEmergencyCallsToPsapEnable)
                }

                if ($call_handling_forwarding_to_other_users.Count -ne 0) {
                    $policy.Add("call_handling_forwarding_to_other_users", $call_handling_forwarding_to_other_users)
                }

                if ($hand_off_to_room.Count -ne 0) {
                    $policy.Add("hand_off_to_room", $hand_off_to_room)
                }

                if ($PSBoundParameters.ContainsKey('PolicyInternationalCallingEnable')) {
                    $policy.Add("international_calling", $PolicyInternationalCallingEnable)
                }

                if ($mobile_switch_to_carrier.Count -ne 0) {
                    $policy.Add("mobile_switch_to_carrier", $mobile_switch_to_carrier)
                }

                if ($select_outbound_caller_id.Count -ne 0) {
                    $policy.Add("select_outbound_caller_id", $select_outbound_caller_id)
                }

                if ($sms.Count -ne 0) {
                    $policy.Add("sms", $sms)
                }

                if ($voicemail.Count -ne 0) {
                    $policy.Add("voicemail", $voicemail)
                }

                if ($voicemail_access_members.Count -ne 0) {
                    $policy.Add("voicemail_access_members", $voicemail_access_members)
                }

                if ($zoom_phone_on_mobile.Count -ne 0) {
                    $policy.Add("zoom_phone_on_mobile", $zoom_phone_on_mobile)
                }

                if ($personal_audio_library.Count -ne 0) {
                    $policy.Add("personal_audio_library", $personal_audio_library)
                }

                if ($voicemail_transcription.Count -ne 0) {
                    $policy.Add("voicemail_transcription", $voicemail_transcription)
                }

                if ($voicemail_notification_by_email.Count -ne 0) {
                    $policy.Add("voicemail_notification_by_email", $voicemail_notification_by_email)
                }

                if ($shared_voicemail_notification_by_email.Count -ne 0) {
                    $policy.Add("shared_voicemail_notification_by_email", $shared_voicemail_notification_by_email)
                }

                if ($check_voicemails_over_phone.Count -ne 0) {
                    $policy.Add("check_voicemails_over_phone", $check_voicemails_over_phone)
                }

                if ($audio_intercom.Count -ne 0) {
                    $policy.Add("audio_intercom", $audio_intercom)
                }

                if ($e2e_encryption.Count -ne 0) {
                    $policy.Add("e2e_encryption", $e2e_encryption)
                }

            #endregion policy

            #region body
                $RequestBody = @{ }

                if ($PSBoundParameters.ContainsKey('EmergencyAddressID')) {
                    $RequestBody.Add("emergency_address_id", $EmergencyAddressID)
                }

                if ($PSBoundParameters.ContainsKey('ExtensionNumber')) {
                    $RequestBody.Add("extension_number", [string]$ExtensionNumber)
                }

                if ($ad_hoc_call_recording.Count -ne 0) {
                    $RequestBody.Add("policy", $policy)
                }

                if ($PSBoundParameters.ContainsKey('SiteId')) {
                    $RequestBody.Add("site_id", $SiteId)
                }

                if ($PSBoundParameters.ContainsKey('TemplateId')) {
                    $RequestBody.Add("template_id", $TemplateId)
                }

            #endregion body

            if ($RequestBody.Count -eq 0) {
                throw 'Request must contain at least one Zoom Phone User change.'
            }

            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
            $Message = 
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $UserId, 'Update')) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}
