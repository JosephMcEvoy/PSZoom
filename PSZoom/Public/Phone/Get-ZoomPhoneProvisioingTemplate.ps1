<#

.SYNOPSIS
Use this API to list all provision templates in a Zoom account.

.DESCRIPTION
Use this API to list all provision templates in a Zoom account.

.PARAMETER ProvisionTemplateID
The provision template ID.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
The full details of each Common Area Phone.

.OUTPUTS
An array of Objects

.EXAMPLE
$AllData = Get-ZoomPhoneProvisioingTemplate

.EXAMPLE
$SomeData = Get-ZoomPhoneProvisioingTemplate -ProvisionTemplateID $SpecificIDsToQuery

.EXAMPLE
$RawData = Get-ZoomPhoneProvisioingTemplate -PageSize 50

.EXAMPLE
$AllData = Get-ZoomPhoneProvisioingTemplate -Full

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listCommonAreas

#>

function Get-ZoomPhoneProvisioingTemplate {

    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string[]]$ProvisionTemplateID,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [parameter(ParameterSetName="AllData")]
        [switch]$Full = $False
     )

    process {
        $baseURI = "https://api.$ZoomURI/v2/phone/provision_templates"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "SelectedRecord" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $ProvisionTemplateID
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize
            }
        }
        
        if ($Full) {
            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty ID
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name
        }

        Write-Output $AggregatedResponse
    }
}