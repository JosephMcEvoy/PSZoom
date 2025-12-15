<#

.SYNOPSIS
Remove all panelists from a webinar.

.DESCRIPTION
Remove all panelists from a webinar.

.PARAMETER WebinarId
The webinar ID.

.EXAMPLE
Remove-ZoomWebinarPanelists -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPanelistsDelete

#>

function Remove-ZoomWebinarPanelists {
    [CmdletBinding(SupportsShouldProcess)]
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
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/panelists"

        if ($PSCmdlet.ShouldProcess($WebinarId, 'Remove all panelists')) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
