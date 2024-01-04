<#

.SYNOPSIS
Create a Block List.

.PARAMETER BlockType
State whether you want the block type to be inbound or outbound.

inbound: Pass this value to prevent the blocked number or prefix from calling into the phone users.

outbound: Pass this value to prevent phone users from calling the blocked number or prefix.
Allowed: inbound┃outbound┃threat

.PARAMETER Comment
Provide a comment to help you identify the blocked number or prefix

.PARAMETER Country
The country information. For example, entering US or CH.

.PARAMETER MatchType
Specify the match type for the blocked list:

phoneNumber: Choose this option (Phone Number Match) if you want to block a specific phone number. Provide the phone number in the phone_number field and the country code in the country field.
prefix: Choose this option (Prefix Match) if you want to block all numbers with a specific country or an area code. Enter a phone number in the phone_number field and in the country field, enter a country code as part of the prefix.

Allowed: phoneNumber┃prefix

.PARAMETER PhoneNumber
The phone number to be blocked if you passed phoneNumber as the value for the match_type field. If you passed prefix as the value for the match_type field, provide the prefix of the phone number in the country field.

.PARAMETER Status
Enable or disable the blocking. One of the following values are allowed:

active: Keep the blocking active.
inactive: Disable the blocking.

Allowed: active┃inactive

.OUTPUTS
Outputs object

.EXAMPLE
Create inbound block list for single number
New-ZoomPhoneBlockList -BlockType "inbound" -Comment "Confirmed Spam Caller" -MatchType "phoneNumber" -PhoneNumber "+19876543210" -Status "active"

.EXAMPLE
Create outbound block list for a prefix
New-ZoomPhoneBlockList -BlockType "outbound" -Comment "Some Random Island" -Country "Kiwis" -MatchType "prefix" -PhoneNumber "+64" -Status "active"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addBlockList

#>

function New-ZoomPhoneBlockList {    
    [CmdletBinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName="PhoneNumberMatch"
    )]
    Param(
        [Parameter(
            Mandatory = $True,
            ParameterSetName="PhoneNumberMatch"
        )]
        [Parameter(
            Mandatory = $True,
            ParameterSetName="PrefixMatch"
        )]
        [ValidateSet("inbound","outbound")]
        [string]$BlockType,

        [Parameter(
            Mandatory = $True,
            ParameterSetName="PhoneNumberMatch"
        )]
        [Parameter(
            Mandatory = $True,
            ParameterSetName="PrefixMatch"
        )]
        [string]$Comment,

        [Parameter(
            Mandatory = $True,
            ParameterSetName="PrefixMatch"
        )]
        [string]$Country,

        [Parameter(
            Mandatory = $True,
            ParameterSetName="PhoneNumberMatch"
        )]
        [Parameter(
            Mandatory = $True,
            ParameterSetName="PrefixMatch"
        )]
        [ValidateSet("phoneNumber","prefix")]
        [string]$MatchType,

        [Parameter(
            Mandatory = $True,
            ParameterSetName="PhoneNumberMatch"
        )]
        [Parameter(
            Mandatory = $True,
            ParameterSetName="PrefixMatch"
        )]
        [string]$PhoneNumber,

        [Parameter(
            Mandatory = $True,
            ParameterSetName="PhoneNumberMatch"
        )]
        [Parameter(
            Mandatory = $True,
            ParameterSetName="PrefixMatch"
        )]
        [ValidateSet("active","inactive")]
        [string]$Status,

        [switch]$PassThru

    )
    
    begin {
        
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/blocked_list"

        #region body
            $RequestBody = @{ }

            $KeyValuePairs = @{
                'block_type'           = $BlockType
                'comment'              = $Comment
                'country'              = $Country
                'match_type'           = $MatchType
                'phone_number'         = $PhoneNumber
                'status'               = $Status
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not (([string]::IsNullOrEmpty($KeyValuePairs.$_)) -or ($KeyValuePairs.$_ -eq 0) )) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }
        #endregion body
        
        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

    }
    process {

$Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $Name, "Create Block List")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
    
            if (-not $PassThru) {
                Write-Output $response
            }
        }
    }    
}
