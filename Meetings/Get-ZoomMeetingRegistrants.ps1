<#

.SYNOPSIS
List registrants of a meeting.
.DESCRIPTION
List registrants of a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OccurenceId
The meeting occurence ID.
.PARAMETER Status
The registrant status:
Pending - Registrant's status is pending.
Approved - Registrant's status is approved.
Denied - Registrant's status is denied.
.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.
.PARAMETER PageNumber
The current page number of returned records. Default value is 1.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomMeetingRegistrants 123456789

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1" -Function 'Get-ZoomApiCredentials','New-JWT','New-ZoomHeaders'

function Get-ZoomMeetingRegistrants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [ValidateSet('pending', 'approved', 'denied')]
        [string]$Status = 'approved',
        
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Alias('page_number')]
        [int]$PageNumber = 1,

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

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/registrants"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $Query = @{
            'status'      = $Status
            'page_size'   = $PageSize
            'page_number' = $PageNumber
        }
        $Request.Query = $Query.ToString()
        
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}