<#

.SYNOPSIS
Create a Call Queue phone account.

.PARAMETER Name
Display name of the Call Queue. Enter at least 3 characters.

.PARAMETER SiteId
Unique identifier of the site to which the Call Queue is assigned.

.PARAMETER Description
Description of the Call Queue.

.PARAMETER ExtensionNumber
Extension number of the Call Queue.

.PARAMETER Timezone
Timezone ID for the Call Queue.

.PARAMETER MaxWaitTime
Maximum wait time in seconds. Range: 10 to 900.

.PARAMETER MaxQueueSize
Maximum number of callers in queue. Range: 1 to 100.

.PARAMETER WrapUpTime
Wrap up time in seconds. Range: 0 to 300.

.PARAMETER PassThru
Return the CallQueueId after creation.

.OUTPUTS
Outputs object

.EXAMPLE
Create new Call Queue account
New-ZoomPhoneCallQueue -Name "Sales_Queue" -SiteId "x3c4v5b6n7ds"

.EXAMPLE
Create Call Queue with additional settings
New-ZoomPhoneCallQueue -Name "Support_Queue" -SiteId "x3c4v5b6n7ds" -Description "Customer Support" -MaxWaitTime 300 -MaxQueueSize 50

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addCallQueue

#>

function New-ZoomPhoneCallQueue {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Name,

        [Parameter(Mandatory = $True)]
        [Alias('site_id')]
        [string]$SiteId,

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

        [switch]$PassThru

    )

    process {

        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues"

        #region body
            $RequestBody = @{ }

            $KeyValuePairs = @{
                'name'              = $Name
                'site_id'           = $SiteId
                'description'       = $Description
                'extension_number'  = $ExtensionNumber
                'timezone'          = $Timezone
                'max_wait_time'     = $MaxWaitTime
                'max_queue_size'    = $MaxQueueSize
                'wrap_up_time'      = $WrapUpTime
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not (([string]::IsNullOrEmpty($KeyValuePairs.$_)) -or ($KeyValuePairs.$_ -eq 0) )) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }
        #endregion body

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

$Message =
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $Name, "Create Call Queue account")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            if (-not $PassThru) {
                Write-Output $response
            }
        }


        if ($PassThru) {
            Write-Output $response.id
        }
    }
}
