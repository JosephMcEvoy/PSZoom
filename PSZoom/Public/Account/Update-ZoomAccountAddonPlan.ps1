<#

.SYNOPSIS
Update an addon plan for a sub account.

.DESCRIPTION
Update an addon plan for a sub account under the master account.

.PARAMETER AccountId
The account ID.

.PARAMETER Type
The addon plan type.

.PARAMETER Hosts
The number of hosts for the addon plan.

.EXAMPLE
Update-ZoomAccountAddonPlan -AccountId 'abc123' -Type 'large_meeting_500' -Hosts 10

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountPlanAddonUpdate

#>

function Update-ZoomAccountAddonPlan {
    [CmdletBinding(SupportsShouldProcess = $True)]
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
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/plans/addons"

        $requestBody = @{
            'type'  = $Type
            'hosts' = $Hosts
        }

        if ($PSCmdlet.ShouldProcess($AccountId, "Update Account Addon Plan")) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Put

            Write-Output $response
        }
    }
}
