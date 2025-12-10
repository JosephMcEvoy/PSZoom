<#

.SYNOPSIS
Update a specific Call Queue account.

.PARAMETER CallQueueId
Unique number used to locate Call Queue account.

.PARAMETER Name
Display name of the Call Queue.

.PARAMETER Description
Description of the Call Queue.

.PARAMETER ExtensionNumber
Extension number of the Call Queue. If the site code is enabled, provide the short extension number instead.

.PARAMETER Timezone
Timezone ID for the Call Queue.

.PARAMETER MaxWaitTime
Maximum wait time in seconds. Range: 10 to 900.

.PARAMETER MaxQueueSize
Maximum number of callers in queue. Range: 1 to 100.

.PARAMETER WrapUpTime
Wrap up time in seconds. Range: 0 to 300.

.PARAMETER CostCenter
The cost center the Call Queue belongs to.

.PARAMETER Department
The department the Call Queue belongs to.

.PARAMETER PassThru
Return the CallQueueId after update.

.OUTPUTS
No output. Can use Passthru switch to pass CallQueueId to output.

.EXAMPLE
Assign new extension number
Update-ZoomPhoneCallQueue -CallQueueId "be5w6n09wb3q567" -ExtensionNumber 011234567

.EXAMPLE
Change Call Queue display name
Update-ZoomPhoneCallQueue -CallQueueId "be5w6n09wb3q567" -Name "Sales Main Line"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateCallQueue

#>

function Update-ZoomPhoneCallQueue {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('id', 'CallQueue_Id')]
        [string]$CallQueueId,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [Alias('extension_number')]
        [int64]$ExtensionNumber,

        [Parameter()]
        [string]$Timezone,

        [Parameter()]
        [ValidateRange(10, 900)]
        [Alias('max_wait_time')]
        [int]$MaxWaitTime,

        [Parameter()]
        [ValidateRange(1, 100)]
        [Alias('max_queue_size')]
        [int]$MaxQueueSize,

        [Parameter()]
        [ValidateRange(0, 300)]
        [Alias('wrap_up_time')]
        [int]$WrapUpTime,

        [Parameter()]
        [Alias('cost_center')]
        [string]$CostCenter,

        [Parameter()]
        [string]$Department,

        [switch]$PassThru
    )

    process {
        foreach ($QueueId in $CallQueueId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$QueueId"

            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'name'              = $Name
                    'description'       = $Description
                    'extension_number'  = $ExtensionNumber
                    'timezone'          = $Timezone
                    'max_wait_time'     = $MaxWaitTime
                    'max_queue_size'    = $MaxQueueSize
                    'wrap_up_time'      = $WrapUpTime
                    'cost_center'       = $CostCenter
                    'department'        = $Department
                }

                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not (([string]::IsNullOrEmpty($KeyValuePairs.$_)) -or ($KeyValuePairs.$_ -eq 0) )) {
                        $RequestBody.Add($_, $KeyValuePairs.$_)
                    }
                }
            #endregion body

            if ($RequestBody.Count -eq 0) {
                Write-Error "Request must contain at least one Call Queue account change."
                return
            }

            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
            $Message =
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $CallQueueId, "Update")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

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
