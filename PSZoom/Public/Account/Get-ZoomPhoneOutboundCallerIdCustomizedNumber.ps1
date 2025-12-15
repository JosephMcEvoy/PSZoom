<#

.SYNOPSIS
List an account's customized outbound caller ID phone numbers.

.DESCRIPTION
Retrieves phone numbers that can be used as the account-level customized outbound caller ID.
Note that when multiple sites policy is enabled, users cannot manage the account-level configuration.
The system will throw an exception.

Prerequisites:
* A Business or Enterprise account
* A Zoom Phone license

Scopes: phone:read:admin
Granular Scopes: phone:read:list_customized_number:admin
Rate Limit Label: Light

.PARAMETER Selected
The status of the phone numbers.
$true - Numbers already added to the custom list.
$false - Numbers not yet added to the custom list.

.PARAMETER SiteId
This field filters phone numbers that belong to the site.

.PARAMETER ExtensionType
The type of extension to which the phone number belongs.

.PARAMETER Keyword
A search keyword for phone or extension numbers.

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken
The next page token paginates through a large set of results.
A next page token is returned whenever the set of available results exceeds the current page size.
The expiration period for this token is 15 minutes.

.OUTPUTS
An object with the Zoom API response containing the customized outbound caller ID phone numbers.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listOutboundCallerIdCustomizedNumbers

.EXAMPLE
Get all customized outbound caller ID phone numbers.
Get-ZoomPhoneOutboundCallerIdCustomizedNumber

.EXAMPLE
Get customized outbound caller ID phone numbers that have been selected.
Get-ZoomPhoneOutboundCallerIdCustomizedNumber -Selected $true

.EXAMPLE
Get customized outbound caller ID phone numbers for a specific site.
Get-ZoomPhoneOutboundCallerIdCustomizedNumber -SiteId "abc123" -PageSize 50

#>

function Get-ZoomPhoneOutboundCallerIdCustomizedNumber {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('selected')]
        [bool]$Selected,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('site_id')]
        [string]$SiteId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [Alias('extension_type')]
        [string]$ExtensionType,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 3
        )]
        [Alias('keyword')]
        [string]$Keyword,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 4
        )]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 5
        )]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/outbound_caller_id/customized_numbers"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('Selected')) {
            $query.Add('selected', $Selected.ToString().ToLower())
        }

        if ($PSBoundParameters.ContainsKey('SiteId')) {
            $query.Add('site_id', $SiteId)
        }

        if ($PSBoundParameters.ContainsKey('ExtensionType')) {
            $query.Add('extension_type', $ExtensionType)
        }

        if ($PSBoundParameters.ContainsKey('Keyword')) {
            $query.Add('keyword', $Keyword)
        }

        if ($PSBoundParameters.ContainsKey('PageSize')) {
            $query.Add('page_size', $PageSize)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
