<#

.SYNOPSIS
Check if an email address is available for registration.

.DESCRIPTION
Check if an email address is available for registration on Zoom.

.PARAMETER Email
The email address to check.

.EXAMPLE
Test-ZoomUserEmail -Email 'newuser@company.com'

.OUTPUTS
Returns an object with 'existed_email' property indicating if the email is already in use.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/userEmail

#>

function Test-ZoomUserEmail {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [string]$Email
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/email"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('email', $Email)
        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
