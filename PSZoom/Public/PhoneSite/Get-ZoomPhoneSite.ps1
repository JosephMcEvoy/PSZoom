<#

.SYNOPSIS
View specific site information in the Zoom Phone account.

.DESCRIPTION
View specific site information in the Zoom Phone account.

.PARAMETER SiteId
The site ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a sites info.
Get-ZoomPhoneSite -SiteId ##########

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-site/getasite

#>

function Get-ZoomPhoneSite {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'site_id')]
        [string[]]$SiteId
     )

    process {
        foreach ($id in $SiteId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/phone/sites/$id"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}