<#

.SYNOPSIS
Update the base plan for a sub account.

.DESCRIPTION
Update the base plan for a sub account under the master account.

.PARAMETER AccountId
The account ID.

.PARAMETER Type
The plan type (e.g., 'pro', 'business', 'edu').

.PARAMETER Hosts
The number of hosts for the plan.

.EXAMPLE
Update-ZoomAccountBasePlan -AccountId 'abc123' -Type 'pro' -Hosts 10

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountPlanBaseUpdate

#>

function Update-ZoomAccountBasePlan {
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

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Type,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [int]$Hosts
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/plans/base"

        $requestBody = @{
            'type'  = $Type
            'hosts' = $Hosts
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Put

        Write-Output $response
    }
}
