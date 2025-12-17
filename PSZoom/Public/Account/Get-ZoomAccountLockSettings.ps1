<#
.SYNOPSIS
Get lock settings for a Zoom account.

.DESCRIPTION
Retrieve the locked settings for an account. Use this API to retrieve the settings that have been locked at the account level and cannot be modified by sub-accounts.

.PARAMETER AccountId
The account ID.

.EXAMPLE
Get-ZoomAccountLockSettings -AccountId "abc123"

.EXAMPLE
"abc123" | Get-ZoomAccountLockSettings

.OUTPUTS
An object containing the account's locked settings.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getAccountLockSettings

#>
function Get-ZoomAccountLockSettings {
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/lock_settings"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
