<#

.SYNOPSIS
Use this API to assign a provision template to a device or remove a provision template from the device by leaving templateId empty.

.PARAMETER DeviceId
Unique number used to locate device.

.PARAMETER ProvisionTemplateId
The provision template ID. The provision template will be removed when this field is left empty.

.PARAMETER PassThru
When switched the command will pass the DeviceId back.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Assign provisoning template to device.
Update-ZoomPhoneDeviceProvisioningTemplate -DeviceId "5d65f7tgy8hu95edr6" -ProvisionTemplateId '5e6r78yb5erc6tv7' 

.EXAMPLE
Remove provionsing template from device.
Update-ZoomPhoneDeviceProvisioningTemplate -DeviceId "5d65f7tgy8hu95edr6"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateProvisionTemplateToDevice


#>

function Update-ZoomPhoneDeviceProvisioningTemplate {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'device_Id')]
        [string[]]$DeviceId,

        [Parameter()]
        [Alias('provision_template_id')]
        [string]$ProvisionTemplateId,


        [switch]$PassThru

    )
    


    process {
        $DeviceId | ForEach-Object {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices/$_/provision_templates"


            #region body
                $RequestBody = @{ }

                $RequestBody.Add("provision_template_id", $ProvisionTemplateId)
            #endregion body


            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



        if ($pscmdlet.ShouldProcess($Message, $_, "Update Provisioning Template")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PUT
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }


        if ($PassThru) {
            Write-Output $DeviceId
        }
    }
}
