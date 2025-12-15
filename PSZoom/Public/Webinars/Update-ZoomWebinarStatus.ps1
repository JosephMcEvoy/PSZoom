<#

.SYNOPSIS
Update a webinar's status.

.DESCRIPTION
Update a webinar's status. Use this API to end an ongoing webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER Action
The action to perform. 'end' to end the webinar.

.EXAMPLE
Update-ZoomWebinarStatus -WebinarId 123456789 -Action 'end'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarStatus

#>

function Update-ZoomWebinarStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateSet('end')]
        [string]$Action
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/status"

        $requestBody = @{
            'action' = $Action
        } | ConvertTo-Json

        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Put

        Write-Output $response
    }
}
