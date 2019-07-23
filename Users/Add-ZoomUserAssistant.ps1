<#

.SYNOPSIS
Add assistants to a user.
.DESCRIPTION
Add assistants to a user. Assistants are the users to whom the current user has assigned  on the user’s behalf.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Assistants
List of user's assistants. User assistant object format:
    Id <string>
    Email <String>
Can also use New-ZoomUserAssistant.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Add-ZoomUserAssistants jmcevoy@lawfirm.com -Assistant (New-ZoomUserAssistant -Id 'jsmith@lawfirm.com' -email 'jsmith@lawfirm.com')
Add-ZoomUserAssistants jmcevoy@lawfirm.com -Assistant (@{'id' = 'jsmith@lawfirm.com', 'email' = 'jsmith@lawfirm.com'})
Add-ZoomUserAssistants jmcevoy@lawfirm.com -Assistants (@{'id' = 'jsmith@lawfirm.com', 'email' = 'jsmith@lawfirm.com'}, @{'id' = 'jrogers@lawfirm.com', 'email' = 'jrogers@lawfirm.com'})
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Add-ZoomUserAssistants {
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

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('assistant')]
        [string[]]$Assistants,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/assistants"
        $RequestBody.Add('assistants', $Assistants)
        $RequestBody = $RequestBody | ConvertTo-Json

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method POST
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        } finally {
                Write-Output $Response
        }
    }      
}

function New-ZoomUserAssistant {
    param (
        [Parameter(Mandatory = $True)]
        [string]$Id,
        
        [Parameter(Mandatory = $True)]
        [string]$Email
    )

    $Assistant = @{
        'id' = $Id
        'email' = $Email
    }

    Write-Output $Assistant
}