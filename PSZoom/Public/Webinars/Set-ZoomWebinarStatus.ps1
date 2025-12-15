<#

.SYNOPSIS
Update a webinar's status.

.DESCRIPTION
Update a webinar's status. Use this API to end an ongoing webinar.

Prerequisites:
* The account must hold a valid Webinar plan.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:update:status, webinar:update:status:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER Action
The action to perform on the webinar status. Use 'end' to end an ongoing webinar.

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarStatus

.EXAMPLE
Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end'

Ends the webinar with ID 123456789.

.EXAMPLE
Get-ZoomWebinar -WebinarId 123456789 | Set-ZoomWebinarStatus -Action 'end'

Ends the webinar using pipeline input.

.EXAMPLE
Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -WhatIf

Shows what would happen if the command were to run without actually executing it.

#>

function Set-ZoomWebinarStatus {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'Id')]
        [int64]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateSet('end')]
        [string]$Action
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/status"

        # Build request body
        $RequestBody = @{
            'action' = $Action
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", "Update status to '$Action'")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method PUT

            Write-Output $response
        }
    }
}
