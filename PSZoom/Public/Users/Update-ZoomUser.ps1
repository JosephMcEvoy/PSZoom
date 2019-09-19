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
.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.
.EXAMPLE`
Update-ZoomUser -UserId helpdesk@lawfirm.com -Type Pro -FirstName Joseph -LastName McEvoy -ApiKey $ApiKey -ApiSecret $ApiSecret
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userupdate

#>
. "$PSScriptRoot\Get-ZoomUser.ps1"

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
        [Alias('Email', 'Emails', 'EmailAddress', 'EmailAddresses', 'Id', 'ids', 'user_id', 'user', 'users', 'userids')]
        [string[]]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Facebook', 'Google', 'API', 'Zoom', 'SSO', 0, 1, 99, 100, 101)]
        [Alias('login_type')]
        [string]$LoginType,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        [string]$Type,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(1, 64)]
        [Alias('first_name')]
        [string]$FirstName,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(1, 64)]
        [Alias('last_name')]
        [string]$LastName,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1000000000, 9999999999)]
        [long]$Pmi = $null,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('use_pmi')]
        [bool]$UsePmi,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({
                (Get-ZoomTimeZones).Contains($_)
        })]
        [string]$Timezone,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Language,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('department')]
        [string]$Dept,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('vanity_name')]
        [string]$VanityName,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidatePattern("[0-9]{6,10}")] #A six to ten digit number.
        [Alias('host_key')]
        [string]$HostKey,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('cms_user_id')]
        [string]$CmsUserId,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,
        
        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$PassThru
    )
    
    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($user in $UserId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user"
            $RequestBody = @{ }   

            if ($PSBoundParameters.ContainsKey('LoginType')) {
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
                'last_name'   = $LastName
                'timezone'    = $Timezone
                'language'    = $Language
                'use_pmi'     = $UsePmi
                'dept'        = $Dept
                'vanity_name' = $VanityName
                'host_key'    = $HostKey
                'cms_user_id' = $CmsUserId
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }

            $RequestBody = $RequestBody | ConvertTo-Json

            if ($pscmdlet.ShouldProcess) {
                try {
                    Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body $RequestBody -Method PATCH
                }
                catch {
                    Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
                }
        
                if (-not $PassThru) {
                    Write-Output $Response
                }
            }
        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}