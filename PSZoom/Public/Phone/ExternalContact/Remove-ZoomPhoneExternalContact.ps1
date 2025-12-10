<#

.SYNOPSIS
Delete a specific external contact.

.DESCRIPTION
Delete a specific external contact from a Zoom Phone account.

.PARAMETER ContactId
The unique identifier of the external contact.

.OUTPUTS
No output. Can use Passthru switch to pass ContactId to output.

.EXAMPLE
Delete an external contact.
Remove-ZoomPhoneExternalContact -ContactId "abc123"

.EXAMPLE
Delete multiple external contacts from pipeline.
"abc123", "xyz456" | Remove-ZoomPhoneExternalContact

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-external-contacts/deleteexternalcontact

#>

function Remove-ZoomPhoneExternalContact {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "High")]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'contact_id')]
        [string[]]$ContactId,

        [switch]$PassThru
    )

    process {
        foreach ($cid in $ContactId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/external_contacts/$cid"

            $Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
"@

            if ($pscmdlet.ShouldProcess($Message, $cid, "Remove External Contact")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $ContactId
        }
    }
}
