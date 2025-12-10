<#

.SYNOPSIS
Unassign phone number from a Call Queue.

.PARAMETER CallQueueId
Unique ID for the Call Queue account.

.PARAMETER NumberId
The phone number or number ID to be unassigned from the Call Queue.

.PARAMETER PassThru
Return the CallQueueId after removing number.

.OUTPUTS
No output. Can use Passthru switch to pass CallQueueId to output.

.EXAMPLE
Remove-ZoomPhoneCallQueueNumber -CallQueueId "5se6dr7ft8ybu9nub" -NumberId "+18011011101"

.EXAMPLE
Remove-ZoomPhoneCallQueueNumber -CallQueueId "5se6dr7ft8ybu9nub" -NumberId "abc123def456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/unassignPhoneNumbersCallQueue

#>

function Remove-ZoomPhoneCallQueueNumber {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'CallQueue_Id')]
        [string]$CallQueueId,

        [Parameter(
            Mandatory = $True,
            Position = 1
        )]
        [Alias('number_id', 'Phone_Number_Id')]
        [string]$NumberId,

        [switch]$PassThru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$CallQueueId/phone_numbers/$NumberId"

$Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
"@

        if ($pscmdlet.ShouldProcess($Message, $CallQueueId, "Removing number $NumberId")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

            if (-not $PassThru) {
                Write-Output $response
            }
        }

        if ($PassThru) {
            Write-Output $CallQueueId
        }
    }
}
