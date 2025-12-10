<#

.SYNOPSIS
Disassociate a sub account from the master account.

.DESCRIPTION
Disassociate a sub account from the master account. This will leave the sub account intact but remove its association with the master account.

.PARAMETER AccountId
The account ID.

.EXAMPLE
Remove-ZoomAccount -AccountId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountDisassociate

#>

function Remove-ZoomAccount {
    [CmdletBinding(SupportsShouldProcess)]
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
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId"

        if ($PSCmdlet.ShouldProcess($AccountId, 'Disassociate account')) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
