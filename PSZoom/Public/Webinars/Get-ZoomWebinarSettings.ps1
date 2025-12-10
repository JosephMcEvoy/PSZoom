<#

.SYNOPSIS
Get a webinar's settings.

.DESCRIPTION
Get a webinar's settings.

.PARAMETER WebinarId
The webinar ID.

.EXAMPLE
Get-ZoomWebinarSettings -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarSettings

#>

function Get-ZoomWebinarSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/settings"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
