<#

.SYNOPSIS
Delete a specific scheduler.

.DESCRIPTION
Delete a specific scheduler. Schedulers are the users to whom the current user has assigned  on the user’s behalf.

.PARAMETER UserId
The user ID or email address.

.PARAMETER SchedulerId
The scheduler ID or email address.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomSpecificUsersSheduler jmcevoy@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userschedulerdelete

#>

function Remove-ZoomSpecificUserScheduler {
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

        [Parameter(
            Mandatory = $True, 
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('scheduler_id')]
        [string[]]$SchedulerId,

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
        foreach ($uid in $UserId) {
            foreach ($sid in $schedulerId) {
                $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$uid/schedulers/$sid"

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
    }
}