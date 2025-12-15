<#

.SYNOPSIS
List tracking fields on an account.

.DESCRIPTION
List tracking fields on an account.

.EXAMPLE
Get-ZoomTrackingFields

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/trackingfieldList

#>

function Get-ZoomTrackingFields {
    [CmdletBinding()]
    param ()

    process {
        $Uri = "https://api.$ZoomURI/v2/tracking_fields"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
