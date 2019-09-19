<#

.SYNOPSIS
Get settings for a group.

.DESCRIPTION
Get settings for a group.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The group ID.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
The Zoom response (an object).

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/getgroupsettings

.EXAMPLE
Get a group's settings.
Get-ZoomGroups | where-object {$_ -match 'Dark Side'} | Get-ZoomGroupSettings

#>

function Get-ZoomGroupSettings  {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials


        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId/settings"

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response   
    }
}