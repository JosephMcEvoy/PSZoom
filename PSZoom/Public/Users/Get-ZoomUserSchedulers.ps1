<#

.SYNOPSIS
List user schedulers.

.DESCRIPTION
List user schedulers.

.PARAMETER UserId
The user ID or email address.

.OUTPUTS
A hastable with the Zoom API response.

.EXAMPLE
Get-ZoomUserSchedulers jmcevoy@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userschedulers

#>

function Get-ZoomUserSchedulers {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string]$UserId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$UserId/schedulers"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        Write-Output $response
    }
}