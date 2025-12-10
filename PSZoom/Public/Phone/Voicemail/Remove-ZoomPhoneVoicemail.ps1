<#

.SYNOPSIS
Delete a voicemail.

.DESCRIPTION
Delete a specific voicemail from Zoom Phone.

.PARAMETER VoicemailId
The voicemail ID.

.PARAMETER PassThru
Pass the VoicemailId to the output.

.OUTPUTS
No output. Can use Passthru switch to pass VoicemailId to output.

.EXAMPLE
Remove-ZoomPhoneVoicemail -VoicemailId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteVoicemail

#>

function Remove-ZoomPhoneVoicemail {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id','Ids', 'voicemail_id')]
        [string[]]$VoicemailId,

        [switch]$PassThru
    )

    process {
        foreach ($vmId in $VoicemailId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/voicemails/$vmId"

            $Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
"@

            if ($pscmdlet.ShouldProcess($Message, $vmId, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $VoicemailId
        }
    }
}
