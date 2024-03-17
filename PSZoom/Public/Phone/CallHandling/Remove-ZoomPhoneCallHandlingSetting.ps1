<#

.SYNOPSIS
Delete call handling settings for a specific Setting Type.

.DESCRIPTION
Delete call handling settings for a specific Setting Type.

.PARAMETER ExtensionId
Unique Identifier of the Extension.

.PARAMETER SettingType
The specific type of calling handling settings
Allowed: business_hours ┃ closed_hours ┃ holiday_hours

.PARAMETER Passthru
Passes ExtensionId back to user after operation

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteCallHandling

.EXAMPLE
List the Holiday Hours Call Handling settings for a extension.
Get-ZoomPhoneUser -userid 'emailaddress@company.com' | Remove-ZoomPhoneCallHandlingSetting -SettingType holiday_hours

#>

function Remove-ZoomPhoneCallHandlingSetting {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('extension_id')]
        [string[]]$ExtensionId,

        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [ValidateSet('business_hours','closed_hours','holiday_hours')]
        [string]$SettingType,

        [switch]$Passthru
     )

    process {

        $ExtensionId | ForEach-Object {

            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/extension/$ExtensionId/call_handling/settings/$($SettingType.ToLower())"

            $Message = 
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

            if ($pscmdlet.ShouldProcess($Message, $_, "Remove $SettingType Settings")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete

                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $ExtensionId
        }
    } 
}

