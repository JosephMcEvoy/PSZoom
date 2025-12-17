<#

.SYNOPSIS
Get the status of a clip transfer.

.DESCRIPTION
Get the status of a clip transfer task. Use this API to check the progress of a clip transfer
operation initiated with Start-ZoomClipTransfer. The response includes the current status and
any relevant transfer details.

Scopes: clip:read, clip:read:admin

.PARAMETER TaskId
The transfer task ID returned from Start-ZoomClipTransfer.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getClipTransferStatus

.EXAMPLE
Get-ZoomClipTransferStatus -TaskId "task123xyz"

Check the status of a clip transfer task.

.EXAMPLE
Start-ZoomClipTransfer -FromUserId "user1@example.com" -ToUserId "user2@example.com" |
    ForEach-Object { Get-ZoomClipTransferStatus -TaskId $_.task_id }

Start a transfer and immediately check its status.

#>

function Get-ZoomClipTransferStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('task_id', 'id')]
        [string[]]$TaskId
    )

    process {
        foreach ($task in $TaskId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/transfers/$task"

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

            Write-Output $response
        }
    }
}
