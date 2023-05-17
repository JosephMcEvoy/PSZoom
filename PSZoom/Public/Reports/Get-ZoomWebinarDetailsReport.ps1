<#

.SYNOPSIS
Retrieve a report containing past webinar details. 

.DESCRIPTION
Retrieve a report containing past webinar details. 

.PARAMETER WebinarId
The webinar ID.

.EXAMPLE
Get-ZoomWebinarDetailsReport 1234567890

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomWebinarDetailsReport {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default',
            Position = 0
        )]
        [Alias('id')]
        [string[]]$WebinarId
    )

    process {
        foreach ($id in $WebinarId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/report/webinars/$WebinarId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
            
            Write-Output $response
        }

    }
}