<#

.SYNOPSIS
Update a group under your account.

.DESCRIPTION
Update a group under your account. This is used to change a group name.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.PARAMETER Name
The group name.

.OUTPUTS
No output.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupupdate

.EXAMPLE
Update-ZoomGroup -GroupId 'Jedi' -Name 'Sith'

#>

function Update-ZoomGroup  {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact= 'Low')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId,

        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [Alias('groupname')]
        [string]$Name
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups/$GroupId"

        $requestBody = @{
            name = $Name
        }

        $requestBody = $requestBody | ConvertTo-Json

        if ($PScmdlet.ShouldProcess($GroupId, 'Update')) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

            Write-Verbose "Changed group name to $Name."
            Write-Output $response
        }
    }
}