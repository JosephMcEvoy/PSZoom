<#

.SYNOPSIS
Use this API to list all the panelists of a Webinar.

.DESCRIPTION
Use this API to list all the panelists of a Webinar.

.PARAMETER WebinarId
The webinar ID.

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
        [bool]$ShowPreviousOccurences
    )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$webinarId/panelists"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET

        Write-Output $response
    }
}