<#

.SYNOPSIS
Get webinar tracking sources.

.DESCRIPTION
Webinar Registration Tracking Sources allow you to see where your registrants are coming from if you share the webinar registration page in multiple platforms. You can then use the source tracking to see the number of registrants generated from each platform.

Use this API to list information on all the tracking sources of a webinar.

Prerequisites:
* Webinar license.
* Registration must be required for the webinar.

Scopes: webinar:read:admin, webinar:read
Granular Scopes: webinar:read:list_tracking_sources, webinar:read:list_tracking_sources:admin
Rate Limit Label: MEDIUM

.PARAMETER WebinarId
The webinar's ID.

.OUTPUTS
An object with the webinar's tracking sources.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getTrackingSources

.EXAMPLE
Get-ZoomWebinarTrackingSource -WebinarId 123456789

.EXAMPLE
123456789 | Get-ZoomWebinarTrackingSource

.EXAMPLE
Get-ZoomWebinar -UserId 'user@example.com' | Get-ZoomWebinarTrackingSource

#>

function Get-ZoomWebinarTrackingSource {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [int64]$WebinarId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/tracking_sources"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
