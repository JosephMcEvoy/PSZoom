<#

.SYNOPSIS
List polls of a webinar.

.DESCRIPTION
List all the polls of a webinar.

.PARAMETER WebinarId
The webinar ID.

.EXAMPLE
Get-ZoomWebinarPolls -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPolls

#>

function Get-ZoomWebinarPolls {
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
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/polls"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
