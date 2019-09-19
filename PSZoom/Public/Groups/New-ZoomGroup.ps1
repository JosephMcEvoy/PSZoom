<#

.SYNOPSIS
Create a group under your account.

.DESCRIPTION
Create a group under your account.
Prerequisite: Pro, Business, or Education account

.PARAMETER Name
The group name.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

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

        [string]$ApiKey,
        
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret

        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups"
    }

    process {
        foreach ($n in $Name) {
            if ($PSCmdlet.ShouldProcess($n, 'New')) {
                $requestBody = @{
                    name = $n
                }

                $requestBody = $requestBody | ConvertTo-Json

                try {
                    $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Body $requestBody -Method POST
                }
                catch {
                    Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
                }

                Write-Verbose "Creating group $n."
                Write-Output $response
            }
        }
    }
}