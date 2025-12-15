<#

.SYNOPSIS
Delete a call log.

.DESCRIPTION
Delete a specific call log from Zoom Phone.

.PARAMETER CallLogId
The call log ID.

.PARAMETER PassThru
Pass the CallLogId to the output.

.OUTPUTS
No output. Can use Passthru switch to pass CallLogId to output.

.EXAMPLE
Remove-ZoomPhoneCallLog -CallLogId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteCallLog

#>

function Remove-ZoomPhoneCallLog {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id','Ids', 'call_log_id')]
        [string[]]$CallLogId,

        [switch]$PassThru
    )

    process {
        foreach ($logId in $CallLogId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_logs/$logId"

            $Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
"@

            if ($pscmdlet.ShouldProcess($Message, $logId, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $CallLogId
        }
    }
}
