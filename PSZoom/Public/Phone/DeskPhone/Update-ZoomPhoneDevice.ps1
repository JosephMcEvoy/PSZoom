<#

.SYNOPSIS
Update information of a desk phone device.
                    
.PARAMETER DeviceId
Unique number used to locate device.

.PARAMETER AssignedTo
User ID or email address of the user to whom this device is to be assigned. The User ID and the email of the user can be retrieved using the List Users API.

.PARAMETER DisplayName
Display name of the desk phone.

.PARAMETER MacAddress
The MAC address of the desk phone.

.PARAMETER ProvisionTemplateId
Provision template id. Supported only by some devices. Empty string represents 'No value set'

.PARAMETER PassThru
When switched the command will pass the DeviceId back.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Assign device to a user.
Update-ZoomPhoneDevice -DeviceId "5d65f7tgy8hu95edr6" -AssignedTo 'askywakler@thejedi.com' 

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateADevice


#>

function Update-ZoomPhoneDevice {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'device_Id')]
        [string]$DeviceId,

        [Parameter()]
        [string]$AssignedTo,

        [Parameter()]
        [string]$DisplayName,

        [Parameter()]
        [ValidateScript({$_ -match "^([0-9A-Fa-f]{2}[:-]?){5}([0-9A-Fa-f]{2})$"})]
        [string]$MacAddress,

        [Parameter()]
        [string]$ProvisionTemplateId,

        [switch]$PassThru

    )
    


    process {
        $DeviceId | ForEach-Object {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices/$_"


            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'assigned_to'              = $AssignedTo
                    'display_name'             = $DisplayName
                    'mac_address'              = $MacAddress
                    'provision_template_id'    = $ProvisionTemplateId
                }
    
                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                        $RequestBody.Add($_, $KeyValuePairs.$_)
                    }
                }
            #endregion body


            if ($RequestBody.Count -eq 0) {

                throw "Request must contain at least one device setting change."

            }


            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



        if ($pscmdlet.ShouldProcess($Message, $_, "Update")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }


        if ($PassThru) {
            Write-Output $_
        }
    }
}
