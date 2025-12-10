<#

.SYNOPSIS
Get plan information for a sub account.

.DESCRIPTION
Get plan information for a sub account under the master account.

.PARAMETER AccountId
The account ID.

.EXAMPLE
Get-ZoomAccountPlans -AccountId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountPlans

#>

function Get-ZoomAccountPlans {
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
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/plans"

        $response = Invoke-ZoomRestMethod -Uri $Uri -Method Get

        Write-Output $response
    }
}
