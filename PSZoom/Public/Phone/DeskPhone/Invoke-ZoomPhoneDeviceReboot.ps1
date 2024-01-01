<#

.SYNOPSIS
Reboots a device.

.PARAMETER DeviceId
Unique identifier of the device.

.OUTPUTS
Outputs object

.EXAMPLE
Reboot zoom device
Invoke-ZoomPhoneDeviceReboot -DeviceId "e5cr6vt7by8nu9mi"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/rebootPhoneDevice


#>

function Invoke-ZoomPhoneDeviceReboot {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'device_Id')]
        [string]$DeviceId

    )
    


    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices/$DeviceId/reboot"
        


$Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



        if ($pscmdlet.ShouldProcess($Message, $DeviceId, "Reboot device")) {
            Invoke-ZoomRestMethod -Uri $request.uri -Method POST
    
        }
    }
}
