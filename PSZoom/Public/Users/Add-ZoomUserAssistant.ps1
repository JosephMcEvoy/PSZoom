<#

.SYNOPSIS
Add assistants to a user.
.DESCRIPTION
Add assistants to a user. Assistants are the users to whom the current user has assigned scheduling privilege on the user’s behalf.
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
Add-ZoomUserAssistants jmcevoy@lawfirm.com -Assistant @((New-ZoomUserAssistant -Id 'jmcevoy@lawfirm.com' -email 'jmcevoy@lawfirm.com'))
Add-ZoomUserAssistants jmcevoy@lawfirm.com -Assistant (@{'id' = 'jsmith@lawfirm.com', 'email' = 'jsmith@lawfirm.com'})
Add-ZoomUserAssistants jmcevoy@lawfirm.com -Assistants (@{'id' = 'jsmith@lawfirm.com', 'email' = 'jsmith@lawfirm.com'}, @{'id' = 'jrogers@lawfirm.com', 'email' = 'jrogers@lawfirm.com'})
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userassistantcreate
.OUTPUTS
A hastable with the Zoom API response.

#>


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
        [System.Array]$Assistants,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/assistants"
        $RequestBody = @{
            'assistants' = $Assistants
        }
        
        $RequestBody = $RequestBody | convertto-json

        $RequestBody
        
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method POST
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        } finally {
            if ($Passthru) {
                Write-Output $UserId
            }
        }
        
        Write-Output $Response
    }      
}

function New-ZoomUserAssistant {
    [CmdletBinding(DefaultParameterSetName = 'Email')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Email,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Id
    )
     
    $Assistant = @{}

    if ($PSBoundParameters.ContainsKey('Email')) {
        $Assistant.Add('email', $Email)
    }

    if ($PSBoundParameters.ContainsKey('Id')) {
        $Assistant.Add('id', $id)
    }
    
    Write-Output $Assistant
}
