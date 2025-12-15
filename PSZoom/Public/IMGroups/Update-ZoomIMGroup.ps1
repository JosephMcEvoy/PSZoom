<#

.SYNOPSIS
Update an IM directory group under an account.

.DESCRIPTION
Update an IM directory group under an account.

.PARAMETER GroupId
The group ID.

.PARAMETER Name
The name of the IM directory group.

.PARAMETER SearchByAccount
Whether members can search for others in the account.

.PARAMETER SearchByDomain
Whether members can search for others in the same email domain.

.PARAMETER SearchByMa
Whether members can search for others within the same master account.

.EXAMPLE
Update-ZoomIMGroup -GroupId 'abc123' -Name 'Updated Team Name'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imGroupUpdate

#>

function Update-ZoomIMGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'group_id')]
        [string]$GroupId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('search_by_account')]
        [bool]$SearchByAccount,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('search_by_domain')]
        [bool]$SearchByDomain,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('search_by_ma')]
        [bool]$SearchByMa
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/im/groups/$GroupId"

        $requestBody = @{}

        $params = @{
            'name'              = 'Name'
            'search_by_account' = 'SearchByAccount'
            'search_by_domain'  = 'SearchByDomain'
            'search_by_ma'      = 'SearchByMa'
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
