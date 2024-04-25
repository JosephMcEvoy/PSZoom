<#

.SYNOPSIS
Update a specific user Zoom Phone Auto Receptionist account.
                    
.PARAMETER AutoReceptionistId
Unique number used to locate Auto Receptionist Phone account.

.PARAMETER AudioPromptId
The audio prompt file ID.

.PARAMETER CallerEntersNoActionResponse
The action if caller enters no action after the prompt played. 
-1 Disconnect the call
-2 Forward to the user
-4 Forward to the common area
-5 Forward to Cisco/Polycom Room
-6 Forward to the auto receptionist
-7 Forward to the call queue
-8 Forward to the shared line group
-15 Forward to the Contact Center

.PARAMETER CallerEntersNoActionPromptRepeat
The number of times to repeat the audio prompt.
Allowed: 1┃2┃3

.PARAMETER CallerEntersNoActionForwardToExtensionId
The extension ID or contact center setting ID.

.PARAMETER HolidayId
The auto receptionist holiday hours ID. If both holiday_id and hours_type are passed, holiday_id has a high priority and hours_type is invalid.

.PARAMETER HoursType
Hours type: business_hours (default) or closed_hours.

.PARAMETER KeyActionResponse
The action after clicking the key.

For key 0-9:
-100 Leave voicemail to the current extension
-200 Leave voicemail to the user
-300 Leave voicemail to the auto receptionist
-400 Leave voicemail to the call queue
-500 Leave voicemail to the shared line group
-2 Forward to the user
-3 Forward to Zoom Room
-4 Forward to the common area
-5 Forward to Cisco/Polycom Room
-6 Forward to the auto receptionist
-7 Forward to the call queue
-8 Forward to the shared line group
-9 Forward to external contacts
-10 Forward to a phone number
-15 Forward to the contact center
-16 Forward to the meeting service
-17 Forward to the meeting service number
-1 Disabled

For key * or #
-21 Repeat menu greeting
-22 Return to the root menu
-23 Return to the previous menu
-1 Disabled

.PARAMETER KeyActionKey
The keypad key. 
The following values are supported: numeric('0'-'9'), *, #.

.PARAMETER KeyActionTargetExtensionId
The extension ID or contact center setting ID.

.PARAMETER KeyActionTargetPhoneNumber
The phone number to forward.

.PARAMETER KeyActionVoicemailGreetingId
The voicemail greeting file ID.


.OUTPUTS
No output. Can use Passthru switch to pass AutoReceptionistId to output.

.EXAMPLE

Update-ZoomPhoneAutoReceptionistIVR -AutoReceptionistId "be5w6n09wb3q567" 

.EXAMPLE

Update-ZoomPhoneAutoReceptionistIVR -AutoReceptionistId "be5w6n09wb3q567" 

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateAutoReceptionistIVR

#>

function Update-ZoomPhoneAutoReceptionistIVR {    
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
        [string]$AudioPromptId,

        [Parameter()]
        [ValidateSet(1,2,4,5,6,7,8,15)]
        [int]$CallerEntersNoActionResponse,

        [Parameter()]
        [ValidateSet(1,2,3)]
        [int]$CallerEntersNoActionPromptRepeat,

        [Parameter()]
        [string]$CallerEntersNoActionForwardToExtensionId,

        [Parameter()]
        [string]$HolidayId,

        [Parameter()]
        [string]$HoursType,

        [Parameter()]
        [ValidateSet(100,200,300,400,500,1,2,3,4,5,6,7,8,9,10,15,15,16,17)]
        [int]$KeyActionResponse,

        [Parameter()]
        [ValidateSet('0','1','2','3','4','5','6','7','8','9','*','#')]
        [string]$KeyActionKey,

        [Parameter()]
        [string]$KeyActionTargetExtensionId,

        [Parameter()]
        [string]$KeyActionTargetPhoneNumber,

        [Parameter()]
        [string]$KeyActionVoicemailGreetingId,

        [switch]$PassThru
    )


    begin {

        #region target
            $target = @{ }

            if ($PSBoundParameters.ContainsKey('KeyActionTargetExtensionId')) {
                $target.Add("extension_id", $KeyActionTargetExtensionId)
            }

            if ($PSBoundParameters.ContainsKey('KeyActionTargetPhoneNumber')) {
                $target.Add("phone_number", $KeyActionTargetPhoneNumber)
            }
        #endregion target

        #region caller_enters_no_action
            $caller_enters_no_action = @{ }

            if ($PSBoundParameters.ContainsKey('CallerEntersNoActionResponse')) {
                $caller_enters_no_action.Add("action", $CallerEntersNoActionResponse)
            }

            if ($PSBoundParameters.ContainsKey('CallerEntersNoActionPromptRepeat')) {
                $caller_enters_no_action.Add("audio_prompt_repeat", $CallerEntersNoActionPromptRepeat)
            }

            if ($PSBoundParameters.ContainsKey('CallerEntersNoActionForwardToExtensionId')) {
                $caller_enters_no_action.Add("forward_to_extension_id", $CallerEntersNoActionForwardToExtensionId)
            }
        #endregion caller_enters_no_action

        #region key_action
            $key_action = @{ }

            if ($PSBoundParameters.ContainsKey('$KeyActionResponse')) {
                $key_action.Add("action", $KeyActionResponse)
            }

            if ($PSBoundParameters.ContainsKey('$KeyActionKey')) {
                $key_action.Add("key", $KeyActionKey)
            }

            if ($PSBoundParameters.ContainsKey('$target')) {
                $key_action.Add("target", $target)
            }

            if ($PSBoundParameters.ContainsKey('$KeyActionVoicemailGreetingId')) {
                $key_action.Add("voicemail_greeting_id", $KeyActionVoicemailGreetingId)
            }
        #endregion key_action

        #region body
            $RequestBody = @{ }

            $KeyValuePairs = @{
                'audio_prompt_id'                 = $AudioPromptId
                'caller_enters_no_action'         = $caller_enters_no_action
                'holiday_id'                      = $HolidayId
                'hours_type'                      = $HoursType
                'key_action'                      = $key_action
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
            
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist/ivr"

            if ($RequestBody.Count -eq 0) {
                Write-Error "Request must contain at least one Auto Receptionist IVR change."
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
