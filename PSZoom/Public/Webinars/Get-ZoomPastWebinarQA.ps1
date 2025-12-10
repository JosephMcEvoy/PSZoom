<#

.SYNOPSIS
Get Q&A report of a past webinar.

.DESCRIPTION
Get Q&A report of a past webinar.

.PARAMETER WebinarId
The webinar ID or UUID.

.EXAMPLE
Get-ZoomPastWebinarQA -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarQA

#>

function Get-ZoomPastWebinarQA {
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
        $Uri = "https://api.$ZoomURI/v2/past_webinars/$WebinarId/qa"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
