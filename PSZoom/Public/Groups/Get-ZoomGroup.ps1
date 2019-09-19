<#

.SYNOPSIS
Get a group under your account.
.DESCRIPTION
Get a group under your account.
Prerequisite: Pro, Business, or Education account
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
Zoom response as an object.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/group
.EXAMPLE
Get-ZoomGroup 24e50639b5bb4fab9c3c

#>

function Get-ZoomGroup  {
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId"

        try {
            $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        } finally {
            Write-Output $response
        }
    }
}