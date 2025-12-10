<#

.SYNOPSIS
Remove a call queue.

.PARAMETER CallQueueId
Unique Identifier of the Call Queue to remove.

.PARAMETER PassThru
Return the CallQueueId after removal.

.OUTPUTS
No output. Can use Passthru switch to pass CallQueueId to output.

.EXAMPLE
Remove-ZoomPhoneCallQueue -CallQueueId "se5d7r6fcvtbyinj"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteCallQueue

#>

function Remove-ZoomPhoneCallQueue {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id','Ids', 'CallQueue_Id')]
        [string[]]$CallQueueId,

        [switch]$PassThru
    )



    process {
        foreach ($QueueId in $CallQueueId) {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$QueueId"

$Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



            if ($pscmdlet.ShouldProcess($Message, $QueueId, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $CallQueueId
        }
    }
}
