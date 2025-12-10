<#

.SYNOPSIS
Get a specific call queue on a Zoom account.

.DESCRIPTION
Get a specific call queue on a Zoom account by ID.

.PARAMETER CallQueueId
Unique Identifier of the Call Queue.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getACallQueue

.EXAMPLE
Return a specific Call Queue by ID.
Get-ZoomPhoneCallQueue -CallQueueId "3vt4b7wtb79q4wvb"

#>

function Get-ZoomPhoneCallQueue {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'CallQueue_Id')]
        [string[]]$CallQueueId
     )

    process {
        foreach ($QueueId in $CallQueueId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$QueueId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
