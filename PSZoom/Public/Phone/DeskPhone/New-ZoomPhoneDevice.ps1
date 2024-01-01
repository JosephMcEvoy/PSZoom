<#

.SYNOPSIS
Adds a new device to Zoom account.

.PARAMETER DisplayName
Display name of the desk phone.

.PARAMETER MacAddress
The MAC address of the desk phone.
Pattern: 001122334455 | 00-11-22-33-44-55 | 00:11:22:33:44:55

.PARAMETER AssignedTo
User ID or email address of the user to whom this device is to be assigned. The User ID and the email of the user can be retrieved using the List Users API.

.PARAMETER AssigneeExtensionIds
Available only for the account that has enabled the common area feature. Extension ID of the user or common area ID.

.PARAMETER Model
Model name of the device.

.PARAMETER Type
Manufacturer (brand) name of the device.

.PARAMETER ProvisionTemplateId
Provision template id. Supported only by some devices. Empty string represents 'No value set'


.OUTPUTS
Outputs object

.EXAMPLE
Create new device
New-ZoomPhoneDevice -DisplayName "DeviceName" -MacAddress 001122334455

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addPhoneDevice


#>

function New-ZoomPhoneDevice {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$DisplayName,

        [Parameter(Mandatory = $True)]
        [ValidateScript({$_ -match "^([0-9A-Fa-f]{2}[:-]?){5}([0-9A-Fa-f]{2})$"})]
        [string]$MacAddress,

        [Parameter(Mandatory = $True)]
        [string]$Type,

        [Parameter()]
        [string]$AssignedTo,

        [Parameter()]
        [string[]]$AssigneeExtensionIds,
        
        [Parameter()]
        [string]$Model,

        [Parameter()]
        [string]$ProvisionTemplateId


    )
    


    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/devices"


        #region body
            $RequestBody = @{ }
            if ($PSBoundParameters.ContainsKey('AssignedTo')) {
                $RequestBody.Add("assigned_to", $AssignedTo)
            }
            if ($PSBoundParameters.ContainsKey('AssigneeExtensionIds')) {
                $RequestBody.Add("assignee_extension_ids", $AssigneeExtensionIds)
            }
            if ($PSBoundParameters.ContainsKey('DisplayName')) {
                $RequestBody.Add("display_name", $DisplayName)
            }
            if ($PSBoundParameters.ContainsKey('MacAddress')) {
                $RequestBody.Add("mac_address", $MacAddress)
            }
            if ($PSBoundParameters.ContainsKey('Model')) {
                $RequestBody.Add("model", $Model)
            }
            if ($PSBoundParameters.ContainsKey('Type')) {
                $RequestBody.Add("type", $Type)
            }
            if ($PSBoundParameters.ContainsKey('ProvisionTemplateId')) {
                $RequestBody.Add("provision_template_id", $ProvisionTemplateId)
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



        if ($pscmdlet.ShouldProcess($Message, $DisplayName, "Create device ")) {

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
    
            Write-Output $response
        }
    }
}
