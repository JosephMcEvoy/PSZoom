<#

.SYNOPSIS
Update a user on your account.

.PARAMETER Type
Basic (1)
Pro (2)
Corp (3)

.PARAMETER LoginType
The user's login method:
0 — FacebookOAuth
1 — GoogleOAuth
24 — AppleOAuth
27 — MicrosoftOAuth
97 — MobileDevice
98 — RingCentralOAuth
99 — APIuser
100 — ZoomWorkemail
101 — SSO

The following login methods are only available in China:
11 — PhoneNumber
21 — WeChat
23 — Alipay

You can use the number or corresponding text (e.g. 'FacebookOauth' or '0').
                    
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

.PARAMETER JobTitle
Users's job title.

.PARAMETER Company
Users's company.

.PARAMETER Location
Users's location.

.PARAMETER PhoneNumber
Deprecated: Phone number of the user, To update you must also provide the PhoneCountry field.

.PARAMETER PhoneCountry
Deprecated: Country ID of the phone number. eg. AU for Australia.

.PARAMETER GroupID
Unique identifier of the group that you would like to add a pending user to.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Update a user's name.
Update-ZoomUser -UserId askywakler@thejedi.com -Type Pro -FirstName Anakin -LastName Skywalker

.EXAMPLE
Update the host key of all users that have 'jedi' in their email.
(Get-ZoomUsers -allpages) | select Email | ? {$_ -like '*jedi*'} | update-zoomuser -hostkey 001138

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userupdate

#>

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
        [Alias('login_type')]
        [string]$LoginType,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        $Type,
        
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
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('job_title')]
        [string]$JobTitle,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Company,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Location,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('phone_number')]
        [string]$PhoneNumber,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('phone_country')]
        [string]$PhoneCountry,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('group_id')]
        [string]$GroupID,

        [switch]$PassThru
    )
    


    process {
        foreach ($user in $UserId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user"
            $RequestBody = @{ }   

            if ($PSBoundParameters.ContainsKey('LoginType')) {
                $LoginType = ConvertTo-LoginTypeCode -Code $LoginType
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
                $query.Add('login_type', $LoginType)
                $Request.Query = $query.ToString()
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
                'first_name'    = $FirstName
                'last_name'     = $LastName
                'timezone'      = $Timezone
                'language'      = $Language
                'use_pmi'       = $UsePmi
                'dept'          = $Dept
                'vanity_name'   = $VanityName
                'host_key'      = $HostKey
                'cms_user_id'   = $CmsUserId
                'job_title'     = $JobTitle
                'company'       = $Company
                'location'      = $Location
                'phone_number'  = $PhoneNumber
                'phone_country' = $PhoneCountry
                'group_id'      = $GroupID
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }

            $RequestBody = $RequestBody | ConvertTo-Json

            if ($pscmdlet.ShouldProcess) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}
