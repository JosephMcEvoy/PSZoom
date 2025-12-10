<#

.SYNOPSIS
Add members to a call queue.

.PARAMETER CallQueueId
Unique Identifier of the Call Queue.

.PARAMETER Members
Array of member objects to add. Each member should be a hashtable with 'id' and 'type' properties.
Type can be 'user', 'commonArea', or 'autoReceptionist'.

.PARAMETER PassThru
Return the CallQueueId after adding members.

.OUTPUTS
No output. Can use Passthru switch to pass CallQueueId to output.

.EXAMPLE
Add a user member to a call queue
$members = @(
    @{
        id = "user123"
        type = "user"
    }
)
Add-ZoomPhoneCallQueueMembers -CallQueueId "queue123" -Members $members

.EXAMPLE
Add multiple members of different types
$members = @(
    @{ id = "user123"; type = "user" },
    @{ id = "common456"; type = "commonArea" }
)
Add-ZoomPhoneCallQueueMembers -CallQueueId "queue123" -Members $members

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addMembersToCallQueue

#>

function Add-ZoomPhoneCallQueueMembers {
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
        [Array]$Members,

        [switch]$PassThru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$CallQueueId/members"

        $RequestBody = @{
            members = $Members
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

$Message =
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $CallQueueId, "Adding members")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            if (-not $PassThru) {
                Write-Output $response
            }
        }

        if ($PassThru) {
            Write-Output $CallQueueId
        }
    }
}
