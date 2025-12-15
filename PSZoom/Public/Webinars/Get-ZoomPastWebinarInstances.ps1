<#

.SYNOPSIS
List past webinar instances.

.DESCRIPTION
List past instances for a webinar.

.PARAMETER WebinarId
The webinar ID.

.EXAMPLE
Get-ZoomPastWebinarInstances -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/pastWebinars

#>

function Get-ZoomPastWebinarInstances {
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
        $Uri = "https://api.$ZoomURI/v2/past_webinars/$WebinarId/instances"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
