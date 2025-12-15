<#

.SYNOPSIS
Add panelists to a webinar.

.DESCRIPTION
Panelists can view and send video, screen share, annotate, etc., in a webinar.
Use this API to add panelists to a scheduled webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER Panelists
Array of panelists. Each panelist should be a hashtable with 'name' and 'email' keys.

.PARAMETER Name
Panelist's name.

.PARAMETER Email
Panelist's email address.

.EXAMPLE
Add-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'

.EXAMPLE
$panelists = @(
    @{ name = 'John Doe'; email = 'john@company.com' },
    @{ name = 'Jane Smith'; email = 'jane@company.com' }
)
Add-ZoomWebinarPanelist -WebinarId 123456789 -Panelists $panelists

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPanelistCreate

#>

function Add-ZoomWebinarPanelist {
    [CmdletBinding(DefaultParameterSetName = 'Single')]
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
        [string]$Email
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/panelists"

        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $requestBody = @{
                'panelists' = @(
                    @{
                        'name'  = $Name
                        'email' = $Email
                    }
                )
            }
        } else {
            $requestBody = @{
                'panelists' = $Panelists
            }
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
