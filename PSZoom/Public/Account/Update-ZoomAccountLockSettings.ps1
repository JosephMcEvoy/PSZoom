<#
.SYNOPSIS
Update lock settings for a Zoom account.

.DESCRIPTION
Update the locked settings for an account. Use this API to update the settings that should be locked at the account level and cannot be modified by sub-accounts.

.PARAMETER AccountId
The account ID.

.PARAMETER Settings
A hashtable containing the lock settings to update. The structure should match the Zoom API requirements for lock settings.

.EXAMPLE
$lockSettings = @{
    schedule_meeting = @{
        host_video = $true
        participant_video = $true
    }
}
Update-ZoomAccountLockSettings -AccountId "abc123" -Settings $lockSettings

.EXAMPLE
"abc123" | Update-ZoomAccountLockSettings -Settings @{ schedule_meeting = @{ host_video = $true } }

.OUTPUTS
Returns $true if the update was successful.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateAccountLockSettings

#>
function Update-ZoomAccountLockSettings {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('account_id', 'id')]
        [string]$AccountId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [hashtable]$Settings
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/lock_settings"

        $requestBody = $Settings

        if ($PSCmdlet.ShouldProcess($AccountId, "Update account lock settings")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Patch -Body $requestBody

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
