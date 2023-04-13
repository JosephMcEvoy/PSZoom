<#

.SYNOPSIS
Revoke a user’s SSO token.

.DESCRIPTION
Revoke a user’s SSO token.

.PARAMETER UserId
The user ID or email address.

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
        [string[]]$UserId,

        [switch]$Passthru
    )

    process {
        foreach ($user in $UserId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$user/token"
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

            if ($Passthru) {
                Write-Output $UserId
            } else {
                Write-Output $response
            }
        }
    }
}