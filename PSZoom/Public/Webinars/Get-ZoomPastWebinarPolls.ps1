<#

.SYNOPSIS
Get poll results of a past webinar.

.DESCRIPTION
Get poll results of a past webinar.

.PARAMETER WebinarId
The webinar ID or UUID.

.EXAMPLE
Get-ZoomPastWebinarPolls -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollResults

#>

function Get-ZoomPastWebinarPolls {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id', 'uuid')]
        [string]$WebinarId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/past_webinars/$WebinarId/polls"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
