<#

.SYNOPSIS
List meetings for a user.
.DESCRIPTION
List meetings for a user.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Type
Scheduled - All of the scheduled meetings.
Live - All of the live meetings.
Upcoming -  All of the upcoming meetings.
.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.
.PARAMETER PageNumber
The current page number of returned records. Default value is 1.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomMeetingsFromuser jsmith@lawfirm.com

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1" -Function 'Get-ZoomApiCredentials','New-JWT','New-ZoomHeaders'

function Get-ZoomMeetingsFromUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id')]
        [string]$UserId,

        [ValidateSet('scheduled', 'live', 'upcoming')]
        [string]$Type = 'live',
        
        [ValidateRange(1, 300)]
        [int]$PageSize = 30,

        [int]$PageNumber = 1,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/meetings"
        $RequestBody = @{ }
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $Query = @{
            'type'        = $Type
            'page_size'   = $PageSize
            'page_number' = $PageNumber
        }
        $Request.Query = $Query.ToString()
        
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}