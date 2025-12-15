<#

.SYNOPSIS
Check if a vanity name is available.

.DESCRIPTION
Check if a personal meeting room vanity name is available for use.

.PARAMETER VanityName
The vanity name to check.

.EXAMPLE
Test-ZoomUserVanityName -VanityName 'mycompany'

.OUTPUTS
Returns an object with 'existed' property indicating if the vanity name is already in use.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/userVanityName

#>

function Test-ZoomUserVanityName {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('vanity_name')]
        [string]$VanityName
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/vanity_name"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('vanity_name', $VanityName)
        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
