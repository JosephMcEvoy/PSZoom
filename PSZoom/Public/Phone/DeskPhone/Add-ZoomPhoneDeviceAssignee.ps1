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
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addExtensionsToADevice

#>

function Add-ZoomPhoneDeviceAssignee {    
    [CmdletBinding(SupportsShouldProcess = $True)]
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


        Update-ZoomPhoneDevice -DeviceId $DeviceId -AssignedTo $UserId


        <#

        $ExtensionId = @()
        $UserId | ForEach-Object {


            $ExtensionId += Get-ZoomPhoneUser -UserId $_ | Select-Object -ExpandProperty extension_id

        }


        $DeviceId | ForEach-Object {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices/$_/extensions"
            $RequestBody = @{ }
            $RequestBody.Add("assignee_extension_ids", $ExtensionId)

            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



            if ($pscmdlet.ShouldProcess($Message, $_, "Adding $UserId association")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method POST
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        #>


        if ($PassThru) {
            Write-Output $_
        }
    }
}
