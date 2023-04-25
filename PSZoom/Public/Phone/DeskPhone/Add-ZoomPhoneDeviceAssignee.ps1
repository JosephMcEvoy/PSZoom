<#

.SYNOPSIS
Use this API to add a desk phone and assign it to a user.

.PARAMETER DeviceId
Unique identifier of the device.

.PARAMETER ExtensionId
Extension ID of the user or common area ID.

.PARAMETER PassThru
When switched the command will pass the DeviceId back.

.OUTPUTS
No output. Can use Passthru switch to pass DeviceId to output.

.EXAMPLE
Add-ZoomPhoneDeviceAssignee -DeviceId "se5d7r6fcvtbyinj" -ExtensionId "4x5ecr6v7tb84zwxe5cr6"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateADevice

#>

function Add-ZoomPhoneDeviceAssignee {    
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'device_Id')]
        [ValidateScript({$DeviceId.count -le 3})]
        [string]$DeviceId,


        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [Alias('User_Id')]
        [string]$UserId,


        [switch]$PassThru
    )
    


    process {

        
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {

            $response = Update-ZoomPhoneDevice -DeviceId $DeviceId -AssignedTo $UserId
    
        }elseif ($PSBoundParameters.ContainsKey('WhatIf')) {

            $response = Update-ZoomPhoneDevice -DeviceId $DeviceId -AssignedTo $UserId -WhatIf

        }

        if (-not $PassThru) {
            Write-Output $response
        }


        if ($PassThru) {
            Write-Output $_
        }
    }
}
