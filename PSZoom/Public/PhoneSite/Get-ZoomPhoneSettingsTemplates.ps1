<#

.SYNOPSIS
View site zoom phone user settings templates.

.DESCRIPTION
View site zoom phone user settings templates.

.PARAMETER templateId
The site ID.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a site's settings templates.
Get-ZoomPhoneSettingsTemplates -templateId ##########

.EXAMPLE
Retrieve inforation for all sites.
Get-ZoomPhoneSettingsTemplates

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listSettingTemplates

#>

function Get-ZoomPhoneSettingsTemplates {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'site_id')]
        [string[]]$templateId,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken

     )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/setting_templates"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $request = [System.UriBuilder]$BASEURI
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                $query.Add('page_size', $PageSize)
                if ($NextPageToken) {
                    $query.Add('next_page_token', $NextPageToken)
                }
                $request.Query = $query.ToString()
                
                $AggregatedResponse = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop


            }
            "SelectedRecord" {

                $AggregatedResponse = @()

                foreach ($id in $templateId) {
                    $request = [System.UriBuilder]$BASEURI
                    $request.path = "{0}/{1}" -f $request.path, $id 
                    $AggregatedResponse += Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop

                }

            }
            "AllData" {

                $PageSize = 30
                $AggregatedResponse = @()

                do {

                    $request = [System.UriBuilder]$BASEURI
                    $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                    $query.Add('page_size', $PageSize)
                    if ($response.next_page_token) {
                        $query.Add('next_page_token', $response.next_page_token)
                    }
                    $request.Query = $query.ToString()
                    
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop

                    if ($response.total_records -ne 0) {
                        $AggregatedResponse += $response | Select-Object -ExpandProperty templates
                    }

                } until (!($response.next_page_token))

            }

        }

        Write-Output $AggregatedResponse 

    }

}