<#

.SYNOPSIS
Remove a desk phone device or ATA (Analog Telephone Adapter) from the Zoom Phone System Management.

.PARAMETER DeviceId
Unique number used to locate device.

.PARAMETER PassThru
When switched the command will pass the DeviceId back.

.OUTPUTS
No output. Can use Passthru switch to pass DeviceId to output.

.EXAMPLE
Remove-ZoomPhoneDevice -DeviceId "se5d7r6fcvtbyinj"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteADevice

#>

function Remove-ZoomPhoneDevice {    
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

        [switch]$PassThru
    )
    


    process {
        $DeviceId | foreach-object {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices/$_"


$Message = 
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



        if ($pscmdlet.ShouldProcess($Message, $_, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
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
