<#

.SYNOPSIS
Get call log details.

.DESCRIPTION
Get detailed information for a specific call log.

.PARAMETER CallLogId
The call log ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Get-ZoomPhoneCallLogDetails -CallLogId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getCallLogDetails

#>

function Get-ZoomPhoneCallLogDetails {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'call_log_id')]
        [string[]]$CallLogId
    )

    process {
        foreach ($logId in $CallLogId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_logs/$logId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
