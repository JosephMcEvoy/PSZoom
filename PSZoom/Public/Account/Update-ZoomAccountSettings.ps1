<#

.SYNOPSIS
Update a sub account's settings under the master account.

.DESCRIPTION
Update a sub account's settings under the master account.

.PARAMETER AccountId
The account ID.

.PARAMETER Option
Optional query parameter to specify settings section: meeting_authentication, recording_authentication, security, meeting_security.

.PARAMETER Settings
Settings object to update.

.EXAMPLE
Update-ZoomAccountSettings -AccountId 'abc123' -Settings @{ schedule_meeting = @{ host_video = $true } }

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountSettingsUpdate

#>

function Update-ZoomAccountSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'account_id')]
        [string]$AccountId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('meeting_authentication', 'recording_authentication', 'security', 'meeting_security')]
        [string]$Option,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [hashtable]$Settings
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/settings"

        if ($PSBoundParameters.ContainsKey('Option')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('option', $Option)
            $Request.Query = $query.ToString()
        }

        $requestBody = $Settings | ConvertTo-Json -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method Patch

        Write-Output $response
    }
}
