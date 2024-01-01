<#

.SYNOPSIS
Update a specific user Zoom Phone account.
                    
.PARAMETER UserId
Unique number used to locate Zoom Phone User account.

.PARAMETER AreaCode
The emergency address ID.

.PARAMETER AudioPromptLanguage
Unique number used to locate Zoom Phone User account.

.PARAMETER CountryIsoCode
The emergency address ID.

.PARAMETER MusicOnHoldId
Unique number used to locate Zoom Phone User account.

.PARAMETER OutboundCallerId
The emergency address ID.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Assign new extension number
Update-ZoomPhoneUser -UserId askywakler@thejedi.com -ExtensionNumber 011234567

.EXAMPLE
Change hold music when user places call into hold state
Update-ZoomPhoneUser -UserId askywakler@thejedi.com -MusicOnHoldId "w98yby73y5ntv3"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateUserSettings


#>

function Update-ZoomPhoneUserSettings {    
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

        [Parameter()]
        [Alias('area_code')]
        [int]$AreaCode,
        
        [Parameter()]
        [Alias('audio_prompt_language')]
        [string]$AudioPromptLanguage,

        [Parameter()]
        [Alias('country_iso_code')]
        [ValidateLength(2,2)]
        [string]$CountryIsoCode,

        [Parameter()]
        [Alias('music_on_hold_id')]
        [string]$MusicOnHoldId,

        [Parameter()]
        [Alias('outbound_caller_id')]
        [string]$OutboundCallerId,
        
        [switch]$PassThru

    )
    


    process {
        foreach ($user in $UserId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user/settings"


            #region body
                $RequestBody = @{ }
                if ($PSBoundParameters.ContainsKey('AreaCode')) {
                    $RequestBody.Add("area_code", [string]$AreaCode)
                }
                if ($PSBoundParameters.ContainsKey('AudioPromptLanguage')) {
                    $RequestBody.Add("audio_prompt_language", $AudioPromptLanguage)
                }
                if ($PSBoundParameters.ContainsKey('CountryIsoCode')) {
                    $RequestBody.Add("country_iso_code", $CountryIsoCode)
                }
                if ($PSBoundParameters.ContainsKey('MusicOnHoldId')) {
                    $RequestBody.Add("music_on_hold_id", $MusicOnHoldId)
                }
                if ($PSBoundParameters.ContainsKey('OutboundCallerId')) {
                    $RequestBody.Add("outbound_caller_id", $OutboundCallerId)
                }
            #endregion body

            if ($RequestBody.Count -eq 0) {

                throw "Request must contain at least one Zoom Phone Setting User change."

            }

            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10


$Message = 
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


        if ($pscmdlet.ShouldProcess($Message, $UserId, "Update settings")) {
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
