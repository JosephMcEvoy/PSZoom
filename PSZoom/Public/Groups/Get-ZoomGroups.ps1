<#

.SYNOPSIS
List groups under your account.

.DESCRIPTION
List groups under your account.
Prerequisite: Pro, Business, or Education account

.PARAMETER FullApiResponse
The switch FullApiResponse will return the default Zoom API response.
The default response looks like:
total_records groups
------------- ------
            9 {@{id=.....

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
The key 'group' of the Zoom response (an object). Example:
id                     name                  total_members
--                     ----                  -------------
wxsZ8asdSdskqOxLPGXqA Light Side                 2
-BqNhqJWQe-Fdro8FMkLA Dark Side                  280

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groups

.EXAMPLE
Get all groups.
Get-ZoomGroups

.EXAMPLE
Get groups that have 'Dark Side' in the name.
((Get-ZoomGroups) | where-object {$_ -eq '*Dark Side*'}).id

.EXAMPLE
Get the default Zoom API response.
Get-ZoomGroups -FullApiResponse

#>

function Get-ZoomGroups  {
    [CmdletBinding()]
    param (
        [switch]$FullApiResponse,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups"

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        if ($FullApiResponse) {
            Write-Output $Response
        } else {
            Write-Output $Response.groups
        }
            
    }
}