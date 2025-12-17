<#
.SYNOPSIS
Get managed domains for a Zoom account.

.DESCRIPTION
Retrieve the managed domains for an account. Managed domains are domains that are associated with the account and can be used for user email addresses.

.PARAMETER AccountId
The account ID.

.EXAMPLE
Get-ZoomAccountManagedDomains -AccountId "abc123"

.EXAMPLE
"abc123" | Get-ZoomAccountManagedDomains

.OUTPUTS
An object containing the account's managed domains.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getAccountManagedDomains

#>
function Get-ZoomAccountManagedDomains {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('account_id', 'id')]
        [string]$AccountId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/managed_domains"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
