<#

.SYNOPSIS
View the details of the Zoom Phone setting template.

.DESCRIPTION
View the details of the Zoom Phone setting template.

.PARAMETER TemplateId
The TemplateID.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
An object with the Zoom API response.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/getsettingtemplate

.EXAMPLE
Return the Zoom phone setting template details of.
Get-ZoomPhoneSettingTemplate ######
Get-ZoomPhoneSettingTemplate -TemplateId ######

#>

function Get-ZoomPhoneSettingTemplate {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'template_id')]
        [string[]]$TemplateId,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($id in $TemplateId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/phone/setting_templates/$id"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret

            Write-Output $response
        }
    }
}