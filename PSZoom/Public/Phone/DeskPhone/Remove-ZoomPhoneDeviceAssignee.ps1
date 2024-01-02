<#

.SYNOPSIS
Use this API to unassign a specific assignee from the device.

.PARAMETER DeviceId
Unique number used to locate device.

.PARAMETER ExtensionId
Extension ID of the assignee (user or common area)
Common Area Extension ID is the same as the Common Area ID

.PARAMETER UnassignAllEntities
Unique number used to locate device.

.PARAMETER PassThru
When switched the command will pass the DeviceId back.

.OUTPUTS
No output. Can use Passthru switch to pass DeviceId to output.

.EXAMPLE
Remove-ZoomPhoneDeviceAssignee -DeviceId "se5d7r6fcvtbyinj"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteExtensionFromADevice

#>

function Remove-ZoomPhoneDeviceAssignee {    
    [CmdletBinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName="UnassignAll"
    )]
    Param(
        [Parameter(ParameterSetName="UnassignSingle")]
        [Parameter(ParameterSetName="UnassignAll")]
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'device_Id')]
        [string]$DeviceId,

        [Parameter(ParameterSetName="UnassignSingle")]
        [string]$ExtensionId,

        [Parameter(ParameterSetName="UnassignAll")]
        [switch]$UnassignAllEntities,

        [Parameter(ParameterSetName="UnassignSingle")]
        [Parameter(ParameterSetName="UnassignAll")]
        [switch]$PassThru
    )
    
    process {

        switch ($PSCmdlet.ParameterSetName) {
            "UnassignAll" {
                $ExtensionId = @()
                $assignee = Get-ZoomPhoneDevice -DeviceId $DeviceId | Select-Object -ExpandProperty assignee

                ForEach ($entity in $assignee) {
                    switch($entity.extension_type) {
                        "user" {
                            $ExtensionId += Get-ZoomPhoneUser -UserId $entity.id | Select-Object -ExpandProperty extension_id
                        }

                        "commonArea" {
                            $ExtensionId += Get-ZoomPhoneCommonArea -CommonAreaId $entity.id | Select-Object -ExpandProperty id
                        }
                    }
                }
            }
        }

        $ExtensionId | ForEach-Object {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices/$DeviceId/extensions/$_"
            $Message = 
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

            if ($pscmdlet.ShouldProcess($Message, $DeviceId, "Removing $_ association")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
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