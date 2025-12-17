<#
.SYNOPSIS
Get settings for a Zoom account.

.DESCRIPTION
Retrieve the settings for an account. Use this API to retrieve settings such as meeting, recording, and telephony settings.

.PARAMETER AccountId
The account ID.

.PARAMETER Option
Optional parameter to filter the type of settings returned. Valid values are 'meeting_authentication', 'recording_authentication', or 'security'.

.EXAMPLE
Get-ZoomAccountSettings -AccountId "abc123"

.EXAMPLE
Get-ZoomAccountSettings -AccountId "abc123" -Option "meeting_authentication"

.EXAMPLE
"abc123" | Get-ZoomAccountSettings

.OUTPUTS
An object containing the account's settings.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getAccountSettings

#>
function Get-ZoomAccountSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $False,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('account_id', 'id')]
        [string]$AccountId = 'me',

        [Parameter(
            Mandatory = $False,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateSet('meeting_authentication', 'recording_authentication', 'security')]
        [string]$Option
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/settings"

        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('Option')) {
            $query.Add('option', $Option)
        }

        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
