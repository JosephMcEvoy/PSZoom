<#

.SYNOPSIS
Update a specific user Zoom Phone account.
                    
.PARAMETER LicenseType
License Type that is to applied to target phone account.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Update-ZoomPhoneUser -UserId askywakler@thejedi.com 

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateUserProfile


#>

function Update-ZoomPhoneUser {    
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
        [Alias('emergency_address', 'Id')]
        [string]$EmergencyAddressID,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('extension_number')]
        [int64]$ExtensionNumber,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('site_id')]
        [string]$SiteId,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('template_id')]
        [string]$TemplateID,
        
        [Parameter()]
        [Alias('international_calling')]
        [bool]$InternationalCalling,
        
        [bool]$EnableVoicemail,

        [switch]$PassThru
    )
    


    process {
        foreach ($user in $UserId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user"
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
