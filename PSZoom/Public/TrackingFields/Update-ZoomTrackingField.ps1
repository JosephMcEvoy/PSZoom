<#

.SYNOPSIS
Update a tracking field.

.DESCRIPTION
Update a tracking field on an account.

.PARAMETER FieldId
The tracking field ID.

.PARAMETER Field
The name of the tracking field.

.PARAMETER RecommendedValues
Array of recommended values for the tracking field.

.PARAMETER Required
Whether the field is required.

.PARAMETER Visible
Whether the field is visible.

.EXAMPLE
Update-ZoomTrackingField -FieldId 'abc123' -Field 'Updated Department'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/trackingfieldUpdate

#>

function Update-ZoomTrackingField {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'field_id')]
        [string]$FieldId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Field,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('recommended_values')]
        [string[]]$RecommendedValues,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Required,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Visible
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/tracking_fields/$FieldId"

        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('Field')) {
            $requestBody['field'] = $Field
        }

        if ($PSBoundParameters.ContainsKey('RecommendedValues')) {
            $requestBody['recommended_values'] = $RecommendedValues -join ','
        }

        if ($PSBoundParameters.ContainsKey('Required')) {
            $requestBody['required'] = $Required
        }

        if ($PSBoundParameters.ContainsKey('Visible')) {
            $requestBody['visible'] = $Visible
        }

        if ($requestBody.Count -gt 0) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Patch
            Write-Output $response
        }
    }
}
