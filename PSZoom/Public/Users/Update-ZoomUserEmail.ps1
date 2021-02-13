<#

.SYNOPSIS
Update a user's email.

.DESCRIPTION
Update a user's email.

.PARAMETER UserId
The user ID or email address.

.PARAMETER Email
User's email. The length should be less than 128 characters.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Update-ZoomUserEmail lskywalker@thejedi.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/useremailupdate

#>

function Update-ZoomUserEmail {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Id')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(0,128)]
        [string]$Email,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/email"

        $requestBody = @{
            'email' = $Email
        } 

        $requestBody = $requestBody | ConvertTo-Json

        Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Body $requestBody -Method PUT -ApiKey $ApiKey -ApiSecret $ApiSecret

        if ($Passthru) {
            Write-Output $UserId
        }
    }
}