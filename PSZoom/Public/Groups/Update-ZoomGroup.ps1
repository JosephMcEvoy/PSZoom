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

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

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
        [string]$Name,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId"

        $requestBody = @{
            name = $Name
        }

        $requestBody = $requestBody | ConvertTo-Json

        if ($PScmdlet.ShouldProcess($GroupId, 'Update')) {
            try {
                $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $requestBody -Method PATCH
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            }

            Write-Verbose "Changed group name to $Name."
            Write-Output $Response
        }
    }
}