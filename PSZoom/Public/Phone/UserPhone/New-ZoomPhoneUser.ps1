<#

.SYNOPSIS
Adds zoom phone user.

.PARAMETER Email
The user email. It ensures the users are active in your Zoom account.

.PARAMETER ExtensionNumber
The extension number. Do not include the site code in an extension number if the site code is enabled.

.PARAMETER CallingPlans
The calling plan.

Type "AU/NZ Metered" if the assigned package is "Australia/New Zealand Metered Calling Plan".
Type "AU/NZ Unlimited" if the assigned package is "Australia/New Zealand Unlimited Calling Plan".
Type "UK/Ireland Metered" if the assigned package is "United Kingdom/Ireland Metered Calling Plan".
Type "UK/Ireland Unlimited" if the assigned package is "United Kingdom/Ireland Unlimited Calling Plan".
Type "US/CA Metered" if the assigned package is "United States/Canada Metered Calling Plan".
Type "US/CA Unlimited" if the assigned package is "United States/Canada Unlimited Calling Plan".
Type "Europe Zone A Metered" if the assigned package is "Europe Zone A Metered Calling Plan".
Type "Europe Zone A Unlimited" if the assigned package is "Europe Zone A Unlimited Calling Plan".
Type "Europe Zone B Metered" if the assigned package is "Europe Zone B Metered Calling Plan".
Type "Europe Zone B Unlimited" if the assigned package is "Europe Zone B Unlimited Calling Plan".
Type "JP Metered" if the assigned package is "Japan Metered Calling Plan".
Type "JP Unlimited" if the assigned package is "Japan Unlimited Calling Plan".
Type "IN Metered" if the assigned package is "India Metered Calling Plan".
Type "IN Unlimited" if the assigned package is "India Unlimited Calling Plan".
Type "IN Pro" if the assigned package is "Zoom Phone India Pro".
Type "IN International Calling Add-On" if the assigned package is "India International Calling Add-On".
Type "Global Select Metered" if the assigned package is "Global Select Metered Calling Plan".
Type "Global Select" if the assigned package is "Global Select Calling Plan".
Type "International Calling Add-On" if the assigned package is "International Calling Add-On".
Type "Beta" if the assigned package is "Beta Calling Plan".
Type "Pro" if the assigned package is "Zoom Phone Pro".
Type "Power Pack" if the assigned package is "Zoom Phone Power Pack". Leave this section blank if no package has been assigned.

.PARAMETER FirstName
The user's first name. It ensures the users are active in your Zoom account.

.PARAMETER LastName
The user's last name. It ensures the users are active in your Zoom account.

.PARAMETER SiteCode
The site code. It's required if the site name is not provided or if Indian plans are assigned.

.PARAMETER SiteName
The site name. It's required if the site code is not provided or if Indian plans are assigned.

.PARAMETER TemplateName
The template name. Configure the user setting according to the specified template. The template must belong to the same site as the user.
 
.PARAMETER PhoneNumbers
The phone numbers in E164 format. Separate multiple phone number entries with commas. Make sure that these numbers have been ported to your account as unassigned phone numbers.

.PARAMETER OutboundCallerId
The outbound caller ID. Hides the caller ID if left blank. You can set an extension's phone number or any company number as the outbound caller ID.

.PARAMETER SelectOutboundCallerId
Whether to allow this extension to change the outbound caller ID when placing calls.

.PARAMETER Sms
Whether to enable SMS for this user.

.PARAMETER DeskPhoneBrand
The manufacturer (brand) name of the device.

.PARAMETER DeskPhoneModel
The model name of the device.

.PARAMETER DeskPhoneMac
The MAC address of the desk phone.

.PARAMETER DeskPhoneTemplate
The provision template name. Supported by select devices.

.OUTPUTS
Outputs object

.EXAMPLE
Create new zoom phone user account from a zoom user
New-ZoomPhoneCommonArea -Email askywakler@thejedi.com -ExtensionNumber 987654321 -CallingPlans "US/CA Unlimited"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/batchAddUsers


#>

function New-ZoomPhoneUser {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Email,

        [Parameter(Mandatory = $True)]
        [int64]$ExtensionNumber,

        [Parameter(Mandatory = $True)]
        [ValidateSet("AU/NZ Metered","AU/NZ Unlimited","UK/Ireland Metered","UK/Ireland Unlimited","US/CA Metered","US/CA Unlimited","Europe Zone A Metered","Europe Zone A Unlimited","Europe Zone B Metered","Europe Zone B Unlimited","JP Metered","JP Unlimited","IN Metered","IN Unlimited","IN Pro","IN International Calling Add-On","Global Select Metered","Global Select","International Calling Add-On","Beta","Pro","Power Pack")]
        [array]$CallingPlans,

        [Parameter()]
        [string]$FirstName,
        
        [Parameter()]
        [string]$LastName,

        [Parameter()]
        [string]$SiteCode,
        
        [Parameter()]
        [string]$SiteName,
                
        [Parameter()]
        [string]$TemplateName,
                        
        [Parameter()]
        [array]$PhoneNumbers,
                        
        [Parameter()]
        [string]$OutboundCallerId,

        [Parameter()]
        [bool]$SelectOutboundCallerId,

        [Parameter()]
        [bool]$Sms,

        [Parameter()]
        [ValidateScript({ $DeskPhoneModel -and $DeskPhoneMac })]
        [string]$DeskPhoneBrand,
        
        [Parameter()]
        [ValidateScript({ $DeskPhoneBrand -and $DeskPhoneMac })]
        [string]$DeskPhoneModel,

        [Parameter()]
        [ValidateScript({ $DeskPhoneBrand -and $DeskPhoneModel -and ($_ -match "^([0-9A-Fa-f]{2}[:-]?){5}([0-9A-Fa-f]{2})$")})]
        [string]$DeskPhoneMac,

        [Parameter()]
        [ValidateScript({ $DeskPhoneBrand -and $DeskPhoneModel -and $DeskPhoneMac })]
        [string]$DeskPhoneTemplate


    )
    


    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/batch"



        #region desk_phones
            $desk_phones_array = @( )
            $desk_phones = @{ }
            if ($PSBoundParameters.ContainsKey('DeskPhoneBrand')) {
                $desk_phones.Add("brand", $DeskPhoneBrand)
            }
            if ($PSBoundParameters.ContainsKey('DeskPhoneModel')) {
                $desk_phones.Add("model", $DeskPhoneModel)
            }
            if ($PSBoundParameters.ContainsKey('DeskPhoneMac')) {
                $desk_phones.Add("mac", $DeskPhoneMac)
            }
            if ($PSBoundParameters.ContainsKey('DeskPhoneTemplate')) {
                $desk_phones.Add("provision_template", $DeskPhoneTemplate)
            }
            if ($desk_phones.count -ne 0) {
                $desk_phones_array.Add($desk_phones)
            }
        #endregion desk_phones


        #region users
            $users = @{}
            $users_array = @()
            $KeyValuePairs = @{
                'email'                        = $Email 
                'first_name'                   = $FirstName
                'last_name'                    = $LastName
                'calling_plans '               = $CallingPlans
                'site_code'                    = $SiteCode
                'site_name'                    = $SiteName
                'template_name'                = $TemplateName
                'extension_number'             = [string]$ExtensionNumber
                'phone_numbers'                = $PhoneNumbers
                'outbound_caller_id'           = $OutboundCallerId
                'select_outbound_caller_id'    = $SelectOutboundCallerId
                'sms'                          = $Sms
                'desk_phones'                  = $desk_phones_array
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $users.Add($_, $KeyValuePairs.$_)
                }
            }
            if ($users.count -ne 0) {
                $users_array.Add($users)
            }
        #endregion users


        #region body
            $RequestBody = @{ }
            if ($users_array.count -ne 0) {
                $RequestBody.Add("users", $users_array)
            }
        #endregion body

        
        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


        if ($pscmdlet.ShouldProcess($Message, $Email, "Create Zoom Phone Account")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
    
            Write-Output $response
        }
    }
}
