<#

.SYNOPSIS
Check if the user’s personal meeting room name exists.
.DESCRIPTION
Check if the user’s personal meeting room name exists.
.PARAMETER VanityName
Personal meeting room name.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
An object with the Zoom API response.
.EXAMPLE
Get-ZoomPersonalMeetingRoomName 'Joes Room'
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/uservanityname

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Get-ZoomPersonalMeetingRoomName {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('vanity_name')]
        [string]$VanityName,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/vanity_name"

        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $Query.Add('vanity_name', $VanityName)
        $Request.Query = $Query.ToString()
    

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}