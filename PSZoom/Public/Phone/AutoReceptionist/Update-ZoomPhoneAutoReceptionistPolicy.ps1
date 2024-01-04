<#

.SYNOPSIS
Update a specific user Zoom Phone Auto Receptionist account.
                    
.PARAMETER AutoReceptionistId
Unique number used to locate Auto Receptionist Phone account.

.PARAMETER VoicemailTranscriptionEnable
Whether to allow users to access transcriptions of voicemails from the Zoom client, the Zoom web portal and email notifications.

.PARAMETER VoicemailTranscriptionReset
Whether the current settings will use the phone account's settings (applicable if the current settings are using the new policy framework).

.PARAMETER VoicemailEmailNotificationEnable
Receive email notifications when there is a new voicemail

.PARAMETER VoicemailEmailNotificationReset
Reset voicemail notification by email settings to default

.PARAMETER VoicemailEmailNotificationEmailForward
Whether to forward the voicemail to email.

.PARAMETER VoicemailEmailNotificationIncludeFile
Whether to include the voicemail file.

.PARAMETER VoicemailEmailNotificationIncludeTranscript
Whether to include the voicemail transcription.

.PARAMETER SmsEnable
Enable to send and receive SMS messages.

.PARAMETER SmsReset
Reset SMS settings to default.

.PARAMETER InternationalSmsEnable
Whether the user can send and receive international messages.

.PARAMETER InternationalSmsCountries
The country which users can send and receive international messages.

.OUTPUTS
No output. Can use Passthru switch to pass AutoReceptionistId to output.

.EXAMPLE
Disable Auto Receptionist from sending email notification for voicemail
Update-ZoomPhoneAutoReceptionistPolicy -AutoReceptionistId "be5w6n09wb3q567" -VoicemailEmailNotificationEnable $false -VoicemailEmailNotificationEmailForward $false -VoicemailEmailNotificationIncludeFile $false -VoicemailEmailNotificationIncludeTranscript $false

.EXAMPLE
Enable Auto Receptionist to make and receive SMS from international countries
Update-ZoomPhoneAutoReceptionistPolicy -AutoReceptionistId "be5w6n09wb3q567" -SmsEnable $true -InternationalSmsEnable $true -InternationalSmsCountries "en-GB"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateAutoReceptionistPolicy

#>

function Update-ZoomPhoneAutoReceptionistPolicy {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('id')]
        [string]$AutoReceptionistId,

        [Parameter()]
        [bool]$VoicemailTranscriptionEnable,

        [Parameter()]
        [bool]$VoicemailTranscriptionReset,

        [Parameter()]
        [bool]$VoicemailEmailNotificationEnable,

        [Parameter()]
        [bool]$VoicemailEmailNotificationReset,

        [Parameter()]
        [bool]$VoicemailEmailNotificationEmailForward,

        [Parameter()]
        [bool]$VoicemailEmailNotificationIncludeFile,

        [Parameter()]
        [bool]$VoicemailEmailNotificationIncludeTranscript,

        [Parameter()]
        [bool]$SmsEnable,

        [Parameter()]
        [bool]$SmsReset,

        [Parameter()]
        [bool]$InternationalSmsEnable,

        [Parameter()]
        [string]$InternationalSmsCountries,

        [switch]$PassThru
    )


    begin {
            #region voicemail_transcription
                $voicemail_transcription = @{ }

                if ($PSBoundParameters.ContainsKey('VoicemailTranscriptionEnable')) {
                    $voicemail_transcription.Add("enable", $VoicemailTranscriptionEnable)
                }

                if ($PSBoundParameters.ContainsKey('VoicemailTranscriptionReset')) {
                    $voicemail_transcription.Add("reset", $VoicemailTranscriptionReset)
                }
            #endregion voicemail_transcription

            #region voicemail_notification_by_email
                $voicemail_notification_by_email = @{ }

                if ($PSBoundParameters.ContainsKey('$VoicemailEmailNotificationIncludeFile')) {
                    $voicemail_notification_by_email.Add("include_voicemail_file", $VoicemailEmailNotificationIncludeFile)
                }

                if ($PSBoundParameters.ContainsKey('$VoicemailEmailNotificationIncludeTranscript')) {
                    $voicemail_notification_by_email.Add("include_voicemail_transcription", $VoicemailEmailNotificationIncludeTranscript)
                }

                if ($PSBoundParameters.ContainsKey('$VoicemailEmailNotificationEnable')) {
                    $voicemail_notification_by_email.Add("enable", $VoicemailEmailNotificationEnable)
                }

                if ($PSBoundParameters.ContainsKey('$VoicemailEmailNotificationReset')) {
                    $voicemail_notification_by_email.Add("reset", $VoicemailEmailNotificationReset)
                }

                if ($PSBoundParameters.ContainsKey('$VoicemailEmailNotificationEmailForward')) {
                    $voicemail_notification_by_email.Add("forward_voicemail_to_email", $VoicemailEmailNotificationEmailForward)
                }
            #endregion voicemail_notification_by_email

            #region sms
                $sms = @{ }

                if ($PSBoundParameters.ContainsKey('$SmsEnable')) {
                    $sms.Add("enable", $SmsEnable)
                }

                if ($PSBoundParameters.ContainsKey('$SmsReset')) {
                    $sms.Add("reset", $SmsReset)
                }

                if ($PSBoundParameters.ContainsKey('$InternationalSmsEnable')) {
                    $sms.Add("international_sms", $InternationalSmsEnable)
                }

                if ($PSBoundParameters.ContainsKey('$InternationalSmsCountries')) {
                    $sms.Add("international_sms_countries", $InternationalSmsCountries)
                }
            #endregion sms
                
            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'voicemail_transcription'          = $voicemail_transcription
                    'voicemail_notification_by_email'  = $voicemail_notification_by_email
                    'sms'                              = $sms
                }
    
                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not (([string]::IsNullOrEmpty($KeyValuePairs.$_)) -or ($KeyValuePairs.$_ -eq 0) )) {
                        $RequestBody.Add($_, $KeyValuePairs.$_)
                    }
                }
            #endregion body

    }
    process {

        foreach ($AutoReceptionist in $AutoReceptionistId) {
            
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist/policies"

            if ($RequestBody.Count -eq 0) {
                Write-Error "Request must contain at least one Auto Receptionist account change."
                return
            }

            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
            $Message = 
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $AutoReceptionistId, "Update")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $AutoReceptionistId
        }
    }
}
