<#

.SYNOPSIS
Get a tracking field.

.DESCRIPTION
Get a specific tracking field on an account.

.PARAMETER FieldId
The tracking field ID.

.EXAMPLE
Get-ZoomTrackingField -FieldId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/trackingfieldGet

#>

function Get-ZoomTrackingField {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'field_id')]
        [string]$FieldId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/tracking_fields/$FieldId"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
