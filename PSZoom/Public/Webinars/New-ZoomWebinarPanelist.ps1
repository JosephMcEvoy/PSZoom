<#
.SYNOPSIS
Add panelists to a webinar.

.DESCRIPTION
Panelists in a webinar can view and send video, screen share, annotate, and do much more compared to attendees in a webinar.
Add panelists to a scheduled webinar.

Prerequisites:
* Pro or a higher plan with the Webinar Add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:write:panelist, webinar:write:panelist:admin
Rate Limit Label: MEDIUM

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER Panelists
Array of panelist objects. Each panelist should be a hashtable with 'name' and 'email' keys.
You can optionally include 'virtual_background_id' key.

.PARAMETER Name
Panelist's name. Use this parameter when adding a single panelist.

.PARAMETER Email
Panelist's email address. Use this parameter when adding a single panelist.

.PARAMETER VirtualBackgroundId
The virtual background ID to bind. Use this parameter when adding a single panelist.

.OUTPUTS
An object with the Zoom API response containing the newly created panelist(s).

.EXAMPLE
New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'

Adds a single panelist named John Doe to the webinar.

.EXAMPLE
New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'Jane Smith' -Email 'jane@company.com' -VirtualBackgroundId 'bg123'

Adds a single panelist with a virtual background assigned.

.EXAMPLE
$panelists = @(
    @{ name = 'John Doe'; email = 'john@company.com' },
    @{ name = 'Jane Smith'; email = 'jane@company.com' }
)
New-ZoomWebinarPanelist -WebinarId 123456789 -Panelists $panelists

Adds multiple panelists to the webinar in a single API call.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPanelistCreate

.LINK
https://support.zoom.us/hc/en-us/articles/115005657826-Inviting-Panelists-to-a-Webinar#h_7550d59e-23f5-4703-9e22-e76bded1ed70

#>

function New-ZoomWebinarPanelist {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low', DefaultParameterSetName = 'Single')]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [int64]$WebinarId,

        [Parameter(
            ParameterSetName = 'Multiple',
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [hashtable[]]$Panelists,

        [Parameter(
            ParameterSetName = 'Single',
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Name,

        [Parameter(
            ParameterSetName = 'Single',
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('email_address')]
        [string]$Email,

        [Parameter(
            ParameterSetName = 'Single',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('virtual_background_id')]
        [string]$VirtualBackgroundId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/panelists"

        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $panelist = @{
                'name'  = $Name
                'email' = $Email
            }

            if ($PSBoundParameters.ContainsKey('VirtualBackgroundId')) {
                $panelist.Add('virtual_background_id', $VirtualBackgroundId)
            }

            $requestBody = @{
                'panelists' = @($panelist)
            }
        } else {
            $requestBody = @{
                'panelists' = $Panelists
            }
        }

        $requestBody = $requestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", "Add panelist(s)")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
