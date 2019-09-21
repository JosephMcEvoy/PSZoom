<#

.SYNOPSIS
Update a user's password.

.DESCRIPTION
Update a user's password.

.PARAMETER UserId
The user ID or email address.

.PARAMETER Password
User password. Minimum of 8 characters. Maximum of 31 characters.

.PARAMETER ApiKey
The API key.

.PARAMETER ApiSecret
THe API secret.

.OUTPUTS
No output. Can use Passthru switch to pass the UserId as an output.

.EXAMPLE
Update-ZoomUserPassword -UserId helpdesk@lawfirm.com -Password 'Zoompassword'

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userpassword

#>

function Update-ZoomUserpassword {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'Emails', 'EmailAddress', 'EmailAddresses', 'Id', 'ids', 'user_id', 'user', 'users', 'userids')]
        [string[]]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateLength(8,31)]
        [string]$Password,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,
        
        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )
    
    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($user in $UserId){
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user/password"
            $requestBody = @{
                'password' = $Password
            }

            $requestBody = $requestBody | ConvertTo-Json

            if ($PSCmdlet.ShouldProcess) {
                try {
                    Invoke-RestMethod -Uri $request.Uri -Headers $Headers -Body $requestBody -Method PUT
                } catch {
                    Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
                }
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }
    }

    end {
        if ($PassThru) {
            Write-Output $UserId
        }
    }
}