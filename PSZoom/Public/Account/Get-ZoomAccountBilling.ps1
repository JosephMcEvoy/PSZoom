<#

.SYNOPSIS
Get billing information for a sub account.

.DESCRIPTION
Get billing information for a sub account under the master account.

.PARAMETER AccountId
The account ID.

.EXAMPLE
Get-ZoomAccountBilling -AccountId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountBilling

#>

function Get-ZoomAccountBilling {
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
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/billing"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
