<#

.SYNOPSIS
List information about a Zoom Phone's call handling settings.

.DESCRIPTION
List information about a Zoom Phone's call handling settings.

.PARAMETER ExtensionId
Unique Identifier of the Extension.

.PARAMETER SettingType
The specific type of calling handling settings
Allowed: business_hours ┃ closed_hours ┃ holiday_hours

.OUTPUTS
An array of Objects

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getCallHandling

.EXAMPLE
List call handling options for specific Extension.
Get-ZoomPhoneCallHandlingSettings -ExtensionId "3vt4b7wtb79q4wvb"

.EXAMPLE
List the Holiday Hours Call Handling settings for a extension.
Get-ZoomPhoneUser -userid 'emailaddress@company.com' | Get-ZoomPhoneCallHandlingSetting -SettingType holiday_hours

#>

function Get-ZoomPhoneCallHandlingSetting {
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('extension_id')]
        [string]$ExtensionId,

        [Parameter()]
        [ValidateSet('business_hours','closed_hours','holiday_hours')]
        [string]$SettingType
     )

    process {

        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/extension/$ExtensionId/call_handling/settings"

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        if ($PSBoundParameters.ContainsKey('SettingType')) {

            $response = $response | Select-Object -ExpandProperty $SettingType
        }
    
        Write-Output $response  
        
    } 
}

