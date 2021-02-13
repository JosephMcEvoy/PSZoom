<#

.SYNOPSIS
Retrieve a report containing past webinar details. 

.DESCRIPTION
Retrieve a report containing past webinar details. 

.PARAMETER WebinarId
The webinar ID.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

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
        [string[]]$WebinarId,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($id in $WebinarId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/webinars/$WebinarId"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
            
            Write-Output $response
        }

    }
}