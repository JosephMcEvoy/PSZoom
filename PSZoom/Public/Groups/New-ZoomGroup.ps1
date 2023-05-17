<#

.SYNOPSIS
Create a group under your account.

.DESCRIPTION
Create a group under your account.
Prerequisite: Pro, Business, or Education account

.PARAMETER Name
The group name.

.OUTPUTS
The Zoom response (an object)
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupcreate

.EXAMPLE
Create two groups.
New-ZoomGroup -name 'Light Side', 'Dark Side'

#>

function New-ZoomGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [Alias('New-ZoomGroups')]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [Alias('groupname', 'groupnames', 'names')]
        [string[]]$Name,

        [switch]$Passthru
    )

    begin {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/groups"
    }

    process {
        foreach ($n in $Name) {
            if ($PSCmdlet.ShouldProcess($n, 'New')) {
                $requestBody = @{
                    name = $n
                }

                $requestBody = $requestBody | ConvertTo-Json

                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method POST

                Write-Verbose "Creating group $n."
                Write-Output $response
            }
        }
    }
}