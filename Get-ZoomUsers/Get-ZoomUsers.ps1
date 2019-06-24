$Parent = Split-Path $PSScriptRoot -Parent
. "$Parent\New-JWT.ps1"
. "$Parent\Read-ZoomResponse.ps1"
. "$Parent\Get-ZoomApiCredentials.ps1"

<#

.SYNOPSIS
List users on a Zoom account.

.DESCRIPTION
List users on a Zoom account.

.PARAMETER Status
User statuses:
Active - Users with an active status. This is the default status.
Inactive - Users with an inactive status.
Pending - Users with a pending status.

.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.

.PARAMETER PageNumber
The current page number of returned records. Default value is 1.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.EXAMPLE
Get-ZoomUsers

.EXAMPLE
Get-ZoomUsers -Status active -PageSize 50

.EXAMPLE
(Get-ZoomUsers -PageSize 100 -pagenumber 3 -status active).Users.Email

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomUsers {
    [CmdletBinding()]
    param (
        [ValidateSet('active', 'inactive', 'pending')]
        [string]$Status = 'active',

        [ValidateRange(1, 300)]
        [int]$PageSize = 30,

        [int]$PageNumber = 1,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        $Uri = "https://api.zoom.us/v2/users/"

        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate JWT (JSON Web Token)
        $token = New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer $ApiKey -SecretKey $ApiSecret -ValidforSeconds 30

        #Generate Header
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Content-Type' , 'application/json')
        $headers.Add('Authorization', 'Bearer ' + $token)
    }

    process {
        $RequestBody = @{ }
        $RequestBody.Add('status', $Status)
        $RequestBody.Add('page_size', $PageSize)
        $RequestBody.Add('page_number', $PageNumber)      
        $Result = Invoke-RestMethod -Uri $Uri -Headers $headers -Body $RequestBody -Method GET | 
        Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Uri
        Write-Output $Result
    }
}