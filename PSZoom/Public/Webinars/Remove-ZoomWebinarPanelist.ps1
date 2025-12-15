<#
.SYNOPSIS
Remove all panelists from a Zoom webinar.

.DESCRIPTION
Remove all the panelists from a webinar.

Prerequisites:
* Pro or a higher plan with the webinar add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:delete:panelist, webinar:delete:panelist:admin

Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Remove-ZoomWebinarPanelist -WebinarId 123456789

Removes all panelists from the webinar with ID 123456789.

.EXAMPLE
123456789 | Remove-ZoomWebinarPanelist

Removes all panelists from the webinar using pipeline input.

.EXAMPLE
Get-ZoomWebinar -WebinarId 123456789 | Remove-ZoomWebinarPanelist

Removes all panelists from a webinar retrieved via Get-ZoomWebinar.

.LINK
https://developers.zoom.us/docs/api/webinars/#tag/webinars/DELETE/webinars/{webinarId}/panelists

#>

function Remove-ZoomWebinarPanelist {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('webinar_id', 'Id')]
        [int64]$WebinarId
    )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/panelists"

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", 'Remove all panelists')) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

            Write-Output $response
        }
    }
}
