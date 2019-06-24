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
Personal Meeting ID, long, length must be 10.
.PARAMETER GroupId
User Group ID. If set default user group, the parameter’s default value is the default user group.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.EXAMPLE
New-ZoomUser -Action ssoCreate -Email helpdesk@foleyhoag.com -Type Pro -FirstName Joseph -LastName McEvoy -ApiKey $ApiKey -ApiSecret $ApiSecret
.OUTPUTS
The Zoom API response as a hashtable.
#>

$Parent = Split-Path $PSScriptRoot -Parent
. "$Parent\New-JWT.ps1"
. "$Parent\Read-ZoomResponse.ps1"
. "$Parent\Get-ZoomApiCredentials.ps1"

function New-ZoomUser {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('create', 'autoCreate', 'custCreate', 'ssoCreate')]
        [string]$Action,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateLength(1, 128)]
        [string]$Email,

        [Parameter(Mandatory = $true)]
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

        [string]$ApiKey,
        
        [string]$ApiSecret
    )
    begin {
        $Uri = 'https://api.zoom.us/v2/users'
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
        $RequestBody = @{ }
        $RequestBody.Add('action', $Action)

        $Type = switch ($Type) {
            'Basic' { 1 }
            'Pro' { 2 }
            'Corp' { 3 }
            Default { $Type }
        }

        #User Info Object
        $UserInfo = @{
            'email' = $Email
            'type'  = $Type
        }

        $UserInfoKeyValues = @{
            'first_name' = $FirstName
            'last_name'  = $LastName
            'password'   = $Password
        }

        #Adds parameters to UserInfo object if not Null
        $UserInfoKeyValues.Keys | ForEach-Object {
            if ($null -ne $AllSettings.$_) {
                $UserInfo.Add($_, $UserInfoKeyValues.$_)
            }
        }
        $RequestBody.add('user_info', $UserInfo)
        if ($pscmdlet.ShouldProcess) {
            $Result = Invoke-RestMethod -Uri $Uri -Headers $Headers -Body ($RequestBody | ConvertTo-Json) -Method Post | 
            Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Uri
        }
        Write-Output $Result
        
    }
}

New-ZoomUser -Action ssoCreate -Email jmcevoyTEST@foleyhoag.com -Type Pro -FirstName Joseph -LastName McEvoy