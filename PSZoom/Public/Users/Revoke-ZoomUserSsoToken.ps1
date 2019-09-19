<#

.SYNOPSIS
Revoke a user’s SSO token.
.DESCRIPTION
Revoke a user’s SSO token.
.PARAMETER UserId
The user ID or email address.
.PARAMETER LoginType
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.
.EXAMPLE
Revoke-UserSsoToken jsmith@lawfirm.com
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userssotokendelete


#>

function Revoke-ZoomUserSsoToken {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string]$UserId,
        
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/token"

        try {
            Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method DELETE
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        } finally {
            if ($Passthru) {
                Write-Output $UserId
            }
        }
    }
}