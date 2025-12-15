<#

.SYNOPSIS
Delete a specific shared line group.

.DESCRIPTION
Delete a specific shared line group from a Zoom Phone account.

.PARAMETER SharedLineGroupId
The unique identifier of the shared line group.

.OUTPUTS
No output. Can use Passthru switch to pass SharedLineGroupId to output.

.EXAMPLE
Delete a shared line group.
Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId "abc123"

.EXAMPLE
Delete multiple shared line groups from pipeline.
"abc123", "xyz456" | Remove-ZoomPhoneSharedLineGroup

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-shared-line-groups/deletesharedlinegroup

#>

function Remove-ZoomPhoneSharedLineGroup {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "High")]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('slgId', 'id', 'shared_line_group_id')]
        [string[]]$SharedLineGroupId,

        [switch]$PassThru
    )

    process {
        foreach ($slgId in $SharedLineGroupId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/shared_line_groups/$slgId"

            $Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
"@

            if ($pscmdlet.ShouldProcess($Message, $slgId, "Remove Shared Line Group")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $SharedLineGroupId
        }
    }
}
