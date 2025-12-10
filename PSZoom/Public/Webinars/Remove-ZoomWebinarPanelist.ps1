<#

.SYNOPSIS
Remove a panelist from a webinar.

.DESCRIPTION
Remove a panelist from a webinar. Panelists can view and send video, screen share, annotate, etc.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER PanelistId
The panelist ID.

.EXAMPLE
Remove-ZoomWebinarPanelist -WebinarId 123456789 -PanelistId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPanelistDelete

#>

function Remove-ZoomWebinarPanelist {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('panelist_id')]
        [string]$PanelistId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/panelists/$PanelistId"

        if ($PSCmdlet.ShouldProcess($PanelistId, "Remove panelist from webinar $WebinarId")) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
