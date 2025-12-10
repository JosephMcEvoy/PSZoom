<#

.SYNOPSIS
Update a specific shared line group.

.DESCRIPTION
Update a specific shared line group on a Zoom Phone account.

.PARAMETER SharedLineGroupId
The unique identifier of the shared line group.

.PARAMETER Name
The name of the shared line group.

.PARAMETER Description
The description of the shared line group.

.PARAMETER ExtensionNumber
The extension number of the shared line group.

.PARAMETER DisplayName
The display name of the shared line group.

.OUTPUTS
No output. Can use Passthru switch to pass SharedLineGroupId to output.

.EXAMPLE
Update shared line group name.
Update-ZoomPhoneSharedLineGroup -SharedLineGroupId "abc123" -Name "New Sales Team"

.EXAMPLE
Update shared line group extension.
Update-ZoomPhoneSharedLineGroup -SharedLineGroupId "abc123" -ExtensionNumber 5050

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-shared-line-groups/updatesharedlinegroup

#>

function Update-ZoomPhoneSharedLineGroup {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('slgId', 'id', 'shared_line_group_id')]
        [string]$SharedLineGroupId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('extension_number')]
        [int]$ExtensionNumber,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('display_name')]
        [string]$DisplayName,

        [switch]$PassThru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/shared_line_groups/$SharedLineGroupId"

        $RequestBody = @{}

        $KeyValuePairs = @{
            'name'             = $Name
            'description'      = $Description
            'extension_number' = $ExtensionNumber
            'display_name'     = $DisplayName
        }

        $KeyValuePairs.Keys | ForEach-Object {
            if ($PSBoundParameters.ContainsKey($_) -or $PSBoundParameters.ContainsKey(($_ -replace '_', ''))) {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }
        }

        if ($RequestBody.Count -eq 0) {
            throw 'Request must contain at least one Shared Line Group change.'
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $Message =
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $SharedLineGroupId, 'Update')) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

            if (-not $PassThru) {
                Write-Output $response
            }
        }

        if ($PassThru) {
            Write-Output $SharedLineGroupId
        }
    }
}
