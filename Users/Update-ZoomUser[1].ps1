<#

.SYNOPSIS
Update a user on your account.
.PARAMETER Type
Basic (1)
Pro (2)
Corp (3)
.PARAMETER FirstName
User's first namee: cannot contain more than 5 Chinese words.
.PARAMETER LastName
User's last name: cannot contain more than 5 Chinese words.
.PARAMETER Pmi
Personal Meeting ID, long, length must be 10.
.PARAMETER UsePmi
Use Personal Meeting ID for instant meetings.
.PARAMETER Language
Language.
.PARAMETER Dept
Department for user profile: use for report.
.PARAMETER VanityName
Personal meeting room name.
.PARAMETER HostKey
Host key. It should be a 6-10 digit number.
.PARAMETER CMSUserId
Kaltura user ID.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.EXAMPLE`
Update-ZoomUser -UserId helpdesk@lawfirm.com -Type Pro -FirstName Joseph -LastName McEvoy -ApiKey $ApiKey -ApiSecret $ApiSecret
.OUTPUTS
The Zoom API response as a hashtable.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"
. "$PSScriptRoot\Get-ZoomSpecificUser.ps1"

function Update-ZoomUser {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email')]
        [string]$UserId,

        [ValidateSet('Facebook', 'Google', 'API', 'Zoom', 'SSO', 0, 1, 99, 100, 101)]
        [string]$LoginType,

        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        [string]$Type,

        [ValidateLength(1, 64)]
        [string]$FirstName,
        
        [ValidateLength(1, 64)]
        [string]$LastName,

        [ValidateRange(1000000000, 9999999999)]
        [long]$Pmi = $null,

        [bool]$UsePmi,

        [ValidateScript({
            (Get-ZoomTimeZones).Contains($_)
        })]
        [string]$Timezone,

        [string]$Language,

        [string]$Dept,

        [string]$VanityName,

        [ValidatePattern("[0-9]{6,10}")] #A six to ten digit number.
        [string]$HostKey,

        [string]$CmsUserId,

        [string]$ApiKey,
        
        [string]$ApiSecret,

        [switch]$PassThru
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId"
        $RequestBody = @{ }   

        if ($LoginType) {
            $LoginType = switch ($LoginType) {
                'Facebook' { 0 }
                'Google' { 1 }
                'API' { 99 }
                'Zoom' { 100 }
                'SSO' { 101 }
                Default { $LoginType }
            }
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $Query.Add('login_type', $LoginType)
            $Request.Query = $Query.ToString()
        }
     
        if ($Type) {
            $Type = switch ($Type) {
                    'Basic' { 1 }
                    'Pro' { 2 }
                    'Corp' { 3 }
                    Default { $Type }
                }
            $RequestBody.Add('type', $Type)
        }

        if ($Pmi -ne 0) {
            $RequestBody.Add('pmi', $Pmi)
        }

        $KeyValuePairs = @{
            'last_name' = $LastName
            'timezone' = $Timezone
            'language' = $Language
            'use_pmi' = $UsePmi
            'dept' = $Dept
            'vanity_name' = $VanityName
            'host_key' = $HostKey
            'cms_user_id' = $CmsUserId
        }

        $KeyValuePairs.Keys | ForEach-Object {
            if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                $RequestBody.Add($_, $KeyValuePairs.$_)
            }
        }

        if ($pscmdlet.ShouldProcess) {
            try {
                Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method Patch
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            } finally {
                if ($PassThru) {
                    if ($_.Exception.Code -ne 404) {
                        Get-ZoomSpecificUser -UserId $UserId
                    }
                }
            }
        }
    }
}