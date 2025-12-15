<#

.SYNOPSIS
Get managed domains for a sub account.

.DESCRIPTION
Get managed domains under the master account.

.PARAMETER AccountId
The account ID.

.EXAMPLE
Get-ZoomAccountManagedDomains -AccountId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountManagedDomain

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
        [Alias('id', 'account_id')]
        [string]$AccountId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/managed_domains"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
