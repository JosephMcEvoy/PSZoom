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
Add an assistant to a user.
Add-ZoomUserAssistants -UserId 'dsidious@thesith.com' -AssistantEmail 'dmaul@thesith.com'

.EXAMPLE
Add assistants to a user.
Add-ZoomUserAssistants -UserId  'okenobi@thejedi.com' -AssistantId '123456789','987654321'

.EXAMPLE
Add assitant to multiple users.
Add-ZoomUserAssistants -UserId  'okenobi@thejedi.com', 'dsidious@thesith.com' -AssistantId 'dvader@thesith.com',

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
        [Alias('Email', 'EmailAddress', 'ID', 'user_id', 'UserIds', 'Emails', 'IDs')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('assistantemails')]
        [string[]]$AssistantEmail,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('assistantids')]
        [string[]]$AssistantId,

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
        foreach ($Id in $UserId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$Id/assistants"

            $assistants = @()
    
            foreach ($email in $AssistantEmail) {
                $assistants += @{'email' = $email}
            }
    
            foreach ($id in $AssistantId) {
                $assistants += @{'id' = $id}
            }
    
            $RequestBody = @{
                'assistants' = $assistants
            }
            
            $RequestBody = $RequestBody | ConvertTo-Json
            
            try {
                $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method POST
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            }
            
            if ($Passthru) {
                Write-Output $UserId
            } else {
                Write-Output $Response
            }
        }
    }
}