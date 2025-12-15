<#

.SYNOPSIS
Delete a tracking field.

.DESCRIPTION
Delete a tracking field from an account.

.PARAMETER FieldId
The tracking field ID.

.EXAMPLE
Remove-ZoomTrackingField -FieldId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/trackingfieldDelete

#>

function Remove-ZoomTrackingField {
    [CmdletBinding(SupportsShouldProcess)]
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

        if ($PSCmdlet.ShouldProcess($FieldId, 'Delete tracking field')) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
