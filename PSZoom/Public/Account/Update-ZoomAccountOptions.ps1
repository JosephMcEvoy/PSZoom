<#

.SYNOPSIS
Update a sub account's options under the master account.

.DESCRIPTION
Update a sub account's options under the master account.

.PARAMETER AccountId
The account ID.

.PARAMETER ShareRc
Enable sharing of premium Room Connector.

.PARAMETER RoomConnectors
Room Connector IDs.

.PARAMETER ShareMc
Enable sharing of Meeting Connector.

.PARAMETER MeetingConnectors
Meeting Connector IDs.

.PARAMETER PayMode
Pay mode. master, sub.

.EXAMPLE
Update-ZoomAccountOptions -AccountId 'abc123' -ShareRc $true

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountOptionsUpdate

#>

function Update-ZoomAccountOptions {
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
        [Alias('share_rc')]
        [bool]$ShareRc,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('room_connectors')]
        [string]$RoomConnectors,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('share_mc')]
        [bool]$ShareMc,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('meeting_connectors')]
        [string]$MeetingConnectors,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('master', 'sub')]
        [Alias('pay_mode')]
        [string]$PayMode
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/options"

        $requestBody = @{}

        $params = @{
            'share_rc'           = 'ShareRc'
            'room_connectors'    = 'RoomConnectors'
            'share_mc'           = 'ShareMc'
            'meeting_connectors' = 'MeetingConnectors'
            'pay_mode'           = 'PayMode'
        }

        foreach ($key in $params.Keys) {
            $paramName = $params[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        if ($requestBody.Count -gt 0) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Patch
            Write-Output $response
        }
    }
}
