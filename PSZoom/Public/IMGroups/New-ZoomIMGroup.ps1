<#

.SYNOPSIS
Create an IM directory group under an account.

.DESCRIPTION
Create an IM directory group under an account.

.PARAMETER Name
The name of the IM directory group.

.PARAMETER SearchByAccount
Whether members can search for others in the account.

.PARAMETER SearchByDomain
Whether members can search for others in the same email domain.

.PARAMETER SearchByMa
Whether members can search for others within the same master account.

.EXAMPLE
New-ZoomIMGroup -Name 'Engineering Team'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imGroupCreate

#>

function New-ZoomIMGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
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
        $Uri = "https://api.$ZoomURI/v2/im/groups"

        $requestBody = @{
            'name' = $Name
        }

        $optionalParams = @{
            'search_by_account' = 'SearchByAccount'
            'search_by_domain'  = 'SearchByDomain'
            'search_by_ma'      = 'SearchByMa'
        }

        foreach ($key in $optionalParams.Keys) {
            $paramName = $optionalParams[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
