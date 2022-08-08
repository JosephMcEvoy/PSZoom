<#

.SYNOPSIS
List user assistants.

.DESCRIPTION
List user assistants.

.PARAMETER UserId
The user ID or email address.

.EXAMPLE
Get-ZoomUserAssistants jmcevoy@lawfirm.com

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomUserAssistants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id', 'userids', 'ids', 'emailaddresses','emails')]
        [string[]]$UserId
     )

    process {
        foreach ($id in $UserId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$Id/assistants"

           $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
    
            Write-Output $response
        }
    }
}