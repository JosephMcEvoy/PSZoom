<#

.SYNOPSIS
Verify if a user’s email is registered with Zoom.

.DESCRIPTION
Verify if a user’s email is registered with Zoom.

.PARAMETER Email
The email address to be verified.

.EXAMPLE
Get-ZoomUserEmailStatus jsmith@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/useremail

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomUserEmailStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True
        )]
        [Alias('EmailAddress', 'Id', 'UserId')]
        [string]$Email
     )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/email"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('email', $Email)
        $Request.Query = $query.ToString()
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        Write-Output $response
    }
}