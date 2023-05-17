<#

.SYNOPSIS
Delete all user schedulers.

.DESCRIPTION
Delete all user schedulers. Schedulers are the users to whom the current user has assigned on the user’s behalf.

.PARAMETER UserId
The user ID or email address.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomUserSchedulers jmcevoy@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userschedulersdelete

#>

function Remove-ZoomUserSchedulers {
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
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$user/schedulers"
    
            Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

            if ($Passthru) {
                Write-Output $UserId
            }
        }
    }
}