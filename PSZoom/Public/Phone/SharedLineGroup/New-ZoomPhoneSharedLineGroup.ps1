<#

.SYNOPSIS
Create a shared line group.

.DESCRIPTION
Create a shared line group on a Zoom Phone account. A shared line group allows Zoom Phone users to receive calls to a shared line and share this line with other members.

.PARAMETER Name
The name of the shared line group.

.PARAMETER Description
The description of the shared line group.

.PARAMETER ExtensionNumber
The extension number of the shared line group.

.PARAMETER SiteId
The unique identifier of the site. This is required if multiple sites are configured.

.PARAMETER DisplayName
The display name of the shared line group.

.OUTPUTS
Outputs object

.EXAMPLE
Create a new shared line group.
New-ZoomPhoneSharedLineGroup -Name "Sales Team" -ExtensionNumber 5001

.EXAMPLE
Create a new shared line group with description.
New-ZoomPhoneSharedLineGroup -Name "Support Team" -ExtensionNumber 5002 -Description "Customer support line" -SiteId "abc123"

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-shared-line-groups/addsharedlinegroup

#>

function New-ZoomPhoneSharedLineGroup {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter(Mandatory = $True)]
        [Alias('extension_number')]
        [int]$ExtensionNumber,

        [Parameter()]
        [Alias('site_id')]
        [string]$SiteId,

        [Parameter()]
        [Alias('display_name')]
        [string]$DisplayName
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/shared_line_groups"

        $RequestBody = @{}

        $KeyValuePairs = @{
            'name'             = $Name
            'description'      = $Description
            'extension_number' = $ExtensionNumber
            'site_id'          = $SiteId
            'display_name'     = $DisplayName
        }

        $KeyValuePairs.Keys | ForEach-Object {
            if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                $RequestBody.Add($_, $KeyValuePairs.$_)
            }
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $Message =
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $Name, "Create Shared Line Group")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
