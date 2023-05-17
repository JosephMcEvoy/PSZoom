<#

.SYNOPSIS
Delete a specific assistant.

.DESCRIPTION
Delete a specific assistant. Assistants are the users to whom the current user has assigned  on the user’s behalf.

.PARAMETER UserId
The user ID or email address.

.OUTPUTS
A hastable with the Zoom API response.

.EXAMPLE
Remove-ZoomSpecificUserAssistant jmcevoy@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userassistantdelete

#>

function Remove-ZoomSpecificUserAssistant {
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
        [Alias('assistant_id')]
        [string[]]$AssistantId
     )

    process {
        foreach ($id in $UserId) {
            foreach ($aid in $AssistantId) {
                $request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$id/assistants/$aid"
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

                Write-Output $response
            }
        }
    }
}