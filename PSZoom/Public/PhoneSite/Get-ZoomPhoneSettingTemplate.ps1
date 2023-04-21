<#

.SYNOPSIS
View zoom phone user settings templates.

.DESCRIPTION
View zoom phone user settings templates.

.PARAMETER templateId
The template Id to be queried.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
The full details of each settings templates.

.OUTPUTS
An array of Objects

.EXAMPLE
Retrieve a site's settings templates.
Get-ZoomPhoneSettingsTemplates -templateId ##########

.EXAMPLE
Retrieve inforation for all settings templates.
Get-ZoomPhoneSettingsTemplates

.EXAMPLE
Retrieve detailed inforation for all settings templates.
Get-ZoomPhoneSettingsTemplates -Full

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listSettingTemplates

#>

function Get-ZoomPhoneSettingTemplate {
    
    [alias("Get-ZoomPhoneSettingsTemplates")]
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param ( 
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'template_Id')]
        [string[]]$templateId,

        [Parameter(
            ParameterSetName="SpecificSite",
            Mandatory = $False, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('site_id')]
        [string[]]$SiteId,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [parameter(ParameterSetName="AllData")]
        [parameter(ParameterSetName="SpecificSite")]
        [switch]$Full = $False

    )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/setting_templates"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize $PageSize -NextPageToken $NextPageToken

            }
            "SelectedRecord" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -ObjectId $templateId

            }
            "AllData" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize 100

            }
            "SpecificSite" {

                $AggregatedResponse = @()
                $SiteId | foreach-object {

                    $QueryStatements = @{"site_id" = $_}
                    $AggregatedResponse += Get-ZoomPaginatedData -URI $BASEURI -PageSize 100 -AdditionalQueryStatements $QueryStatements

                }
            }
        }

        if ($Full) {

            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty ID
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name

        }

        Write-Output $AggregatedResponse

    }	
}