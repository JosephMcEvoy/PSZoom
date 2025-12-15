<#

.SYNOPSIS
List an account's Zoom phone settings.

.DESCRIPTION
Returns an account's Zoom phone settings.

Prerequisites:
* A Business or Enterprise account 
* A Zoom Phone license

Scopes: phone:read:admin
Granular Scopes: phone:read:list_account_settings:admin
Rate Limit Label: LIGHT

.PARAMETER SettingTypes
The comma separated list of the setting items you want to fetch. Allowed values: 
call_live_transcription, local_survivability_mode, external_calling_on_zoom_room_common_area, 
select_outbound_caller_id, personal_audio_library, voicemail, voicemail_transcription, 
voicemail_notification_by_email, shared_voicemail_notification_by_email, restricted_call_hours, 
allowed_call_locations, check_voicemails_over_phone, auto_call_recording, ad_hoc_call_recording, 
international_calling, outbound_calling, outbound_sms, sms, sms_etiquette_tool, zoom_phone_on_mobile, 
zoom_phone_on_pwa, e2e_encryption, call_handling_forwarding_to_other_users, call_overflow, 
call_transferring, elevate_to_meeting, call_park, hand_off_to_room, mobile_switch_to_carrier, 
delegation, audio_intercom, block_calls_without_caller_id, block_external_calls, call_queue_opt_out_reason, 
auto_delete_data_after_retention_duration, auto_call_from_third_party_apps, override_default_port, 
peer_to_peer_media, advanced_encryption, display_call_feedback_survey, block_list_for_inbound_calls_and_messaging, 
block_calls_as_threat.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getPhoneAccountSettings

.EXAMPLE
Get-ZoomPhoneAccountSettings

Returns all Zoom Phone account settings.

.EXAMPLE
Get-ZoomPhoneAccountSettings -SettingTypes "voicemail,sms"

Returns only the voicemail and SMS settings for the Zoom Phone account.

.EXAMPLE
Get-ZoomPhoneAccountSettings -SettingTypes "auto_call_recording,ad_hoc_call_recording,e2e_encryption"

Returns call recording and encryption settings for the Zoom Phone account.

#>

function Get-ZoomPhoneAccountSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('setting_types')]
        [string]$SettingTypes
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/account_settings"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('SettingTypes')) {
            $query.Add('setting_types', $SettingTypes)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
