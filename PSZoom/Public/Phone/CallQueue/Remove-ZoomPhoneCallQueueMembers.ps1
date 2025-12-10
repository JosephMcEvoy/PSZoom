<#

.SYNOPSIS
Remove members from a call queue.

.PARAMETER CallQueueId
Unique Identifier of the Call Queue.

.PARAMETER MemberIds
Array of member IDs to remove from the call queue.

.PARAMETER PassThru
Return the CallQueueId after removing members.

.OUTPUTS
No output. Can use Passthru switch to pass CallQueueId to output.

.EXAMPLE
Remove a single member from a call queue
Remove-ZoomPhoneCallQueueMembers -CallQueueId "queue123" -MemberIds "member123"

.EXAMPLE
Remove multiple members from a call queue
Remove-ZoomPhoneCallQueueMembers -CallQueueId "queue123" -MemberIds "member123","member456"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteMembersOfCallQueue

#>

function Remove-ZoomPhoneCallQueueMembers {
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
        [Alias('member_ids')]
        [string[]]$MemberIds,

        [switch]$PassThru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$CallQueueId/members"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        # Add member_ids as comma-separated query parameter
        $query.Add('member_ids', ($MemberIds -join ','))

        $Request.Query = $query.ToString()

$Message =
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
"@

        if ($pscmdlet.ShouldProcess($Message, $CallQueueId, "Removing members")) {
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
