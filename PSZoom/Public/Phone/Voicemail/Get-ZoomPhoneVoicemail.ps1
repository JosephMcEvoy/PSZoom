<#

.SYNOPSIS
Get voicemail details.

.DESCRIPTION
Get detailed information for a specific voicemail.

.PARAMETER VoicemailId
The voicemail ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Get-ZoomPhoneVoicemail -VoicemailId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getVoicemail

#>

function Get-ZoomPhoneVoicemail {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'voicemail_id')]
        [string[]]$VoicemailId
    )

    process {
        foreach ($vmId in $VoicemailId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/voicemails/$vmId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
