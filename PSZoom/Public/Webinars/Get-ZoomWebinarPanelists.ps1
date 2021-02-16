<#

.SYNOPSIS
Use this API to list all the panelists of a Webinar.

.DESCRIPTION
Use this API to list all the panelists of a Webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS

.LINK

.EXAMPLE
Get-ZoomWebinarPanelists 1234567890

#>

function Get-ZoomWebinarPanelists {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id')]
        [int64]$WebinarId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('ocurrence_id')]
        [string]$OccurrenceId,

        [ALias('show_previous_occurences')]
        [bool]$ShowPreviousOccurences,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
 
        #Generate Headers and JWT (JSON Web Token)
        $headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $request = [System.UriBuilder]"https://api.zoom.us/v2/webinars/$webinarId/panelists"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Body $RequestBody -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret

        Write-Output $response
    }
}