<#

.SYNOPSIS
List of Zoom Phone template settings.

.DESCRIPTION
This API lets you retrieve a list of all the phone template settings previously created. 

.PARAMETER SiteId
The site ID.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listsettingtemplates

.EXAMPLE
Return the first page of Zoom phone users.
Get-ZoomPhoneSettingTemplates

.EXAMPLE
Return the first page of Phone setting templates
Get-ZoomPhoneSettingTemplates

.EXAMPLE
Return the first page of Phone setting templates for SiteId, refer to Get-ZoomPhoneSites to find SiteId
Get-ZoomPhoneSettingTemplates -Full
Get-ZoomPhoneSettingTemplates -SiteId ###### -Full
#>

function Get-ZoomPhoneSettingTemplates {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $False, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('site_id')]
        [int]$SiteId,
		
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [switch]$Full = $False,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $request = [System.UriBuilder]'https://api.zoom.us/v2/phone/setting_templates/'
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)
        $query.Add('page_number', $PageNumber)

        if ($PSBoundParameters.ContainsKey('SiteId')) {
            $query.Add('site_id', $SiteId)
        }
        
        $request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        if ($Full) {
            Write-Output $response
        } else {
            Write-Output $response.Templates
        }
    }
}