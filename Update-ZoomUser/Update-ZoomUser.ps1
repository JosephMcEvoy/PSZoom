<#
.SYNOPSIS
Create a user using your account.
.PARAMETER Action
Specify how to create the new user:
create - User will get an email sent from Zoom. There is a confirmation link in this email. The user will then need to use the link to activate their Zoom account. 
The user can then set or change their password.
autoCreate - This action is provided for the enterprise customer who has a managed domain. This feature is 
disabled by default because of the security risk involved in creating a user who does not belong to your domain.
custCreate - This action is provided for API partners only. A user created in this way has no password and 
is not able to log into the Zoom web site or client.
ssoCreate - This action is provided for the enabled “Pre-provisioning SSO User” option. A user created in 
this way has no password. If not a basic user, a personal vanity URL using the user name (no domain) of 
the provisioning email will be generated. If the user name or PMI is invalid or occupied, it will use a random 
number or random personal vanity URL.
.PARAMETER Email
User email address.
.PARAMETER Type
Basic (1)
Pro (2)
Corp (3)
.PARAMETER FirstName
User's first namee: cannot contain more than 5 Chinese words.
.PARAMETER LastName
User's last name: cannot contain more than 5 Chinese words.
.PARAMETER PASSWORD
User password. Only used for the "autoCreate" function. The password has to have a minimum of 8 characters and maximum of 32 characters. 
It must have at least one letter (a, b, c..), at least one number (1, 2, 3...) and include both uppercase and lowercase letters. 
It should not contain only one identical character repeatedly ('11111111' or 'aaaaaaaa') and it cannot contain consecutive characters ('12345678' or 'abcdefgh').
.PARAMETER Pmi
Personal Meeting ID. Length must be 10.
.PARAMETER UsePmi
Use Personal Meeting ID for instant meetings.
.PARAMETER Timezone
The time zone ID for a user profile. FOr this parameter value please refer to the ID value in the timezone list. 
https://marketplace.zoom.us/docs/api-reference/other-references/abbreviation-lists#timezones
.PARAMETER Dept
Department for usre profile: use for report.
.PARAMETER VanityName
Personal meeting room name.
.PARAMETER HostKey
Host key. It should be a 6-10 digit number.
.PARAMETER CmsUserId
Kaltura user ID.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.EXAMPLE
Update-ZoomUser
.OUTPUTS
The Zoom API response as a hashtable.
.LINK
https://marketplace.zoom.us/docs/api-reference/other-references/abbreviation-lists#timezones
#>

$Parent = Split-Path $PSScriptRoot -Parent
. "$Parent\New-JWT.ps1"
. "$Parent\Read-ZoomResponse.ps1"
. "$Parent\Get-ZoomApiCredentials.ps1"
. "$Parent\Get-ZoomTimeZones.ps1"
    
function Update-ZoomUser {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$UserId,

        [ValidateSet('0', '1', '99', '100', '101')]
        [string]$LoginType,

        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 64)]
        [string]$FirstName,
        
        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 64)]
        [string]$LastName,

        [Parameter(Mandatory = $false)]
        [string]$Password,

        [ValidateRange(1000000000, 9999999999)]
        [long]$Pmi,

        [bool]$UsePmi = $false,

        [ValidateScript( {
                (Get-ZoomTimeZones).Contains($_)
        })]
        [string]$Timezone,

        [string]$Language,

        [string]$Dept,

        [string]$VanityName,

        [ValidatePattern('([0-9]{6,10})')] #6 digit minimum, 10 digit maximum
        [long]$HostKey,

        [string]$CMSUserId,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
        $Uri = "https://api.zoom.us/v2/users/$UserId"
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
        #Request Body
        $RequestBody = @{
            'user_id' = $UserId
        }

        if ($Type) {
            $Type = switch ($Type) {
                'Basic' { 1 }
                'Pro'   { 2 }
                'Corp'  { 3 }
                Default { $Type }
            }
        }

        $AllKeyValues = @{
            'first_name'  = $FirstName
            'last_name'   = $LastName
            'type'        = $Type
            'pmi'         = $Pmi
            'use_pmi'     = $UsePmi
            'timezone'    = $Timezone
            'language'    = $Language
            'dept'        = $Dept
            'vanity_name' = $VanityName
            'host_key'    = $VanityName
            'cms_user_id' = $CMSUserId
        }

        #Adds parameters to UserInfo object if not Null
        $AllKeyValues.Keys | ForEach-Object {
            if ($null -ne $AllSettings.$_) {
                $RequestBody.Add($_, $AllKeyValues.$_)
            }
        }

        if ($pscmdlet.ShouldProcess) {
            $Result = Invoke-RestMethod -Uri $Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method Patch | 
            Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Uri
        }

        Write-Output $Result
        
    }
}

update-zoomuser -userid jmcevoyTEST@foleyhoag.com -hostkey 123456