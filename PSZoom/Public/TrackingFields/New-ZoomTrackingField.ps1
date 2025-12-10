<#

.SYNOPSIS
Create a tracking field.

.DESCRIPTION
Create a tracking field on an account.

.PARAMETER Field
The name of the tracking field.

.PARAMETER RecommendedValues
Array of recommended values for the tracking field.

.PARAMETER Required
Whether the field is required.

.PARAMETER Visible
Whether the field is visible.

.EXAMPLE
New-ZoomTrackingField -Field 'Department' -RecommendedValues @('Sales', 'Engineering', 'HR')

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/trackingfieldCreate

#>

function New-ZoomTrackingField {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [string]$Field,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('recommended_values')]
        [string[]]$RecommendedValues,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Required = $false,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Visible = $true
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/tracking_fields"

        $requestBody = @{
            'field'    = $Field
            'required' = $Required
            'visible'  = $Visible
        }

        if ($PSBoundParameters.ContainsKey('RecommendedValues')) {
            $requestBody['recommended_values'] = $RecommendedValues -join ','
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
