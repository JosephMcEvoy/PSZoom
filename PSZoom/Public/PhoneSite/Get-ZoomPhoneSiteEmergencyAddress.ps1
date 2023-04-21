<#

.SYNOPSIS
View site emergency address information.

.DESCRIPTION
View site emergency address information.

.PARAMETER EmergencyAddressId
The Emergency Address Id to be queried.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
The full details of each Common Area Phone.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a specific Emergency Address.
Get-ZoomPhoneSiteEmergencyAddress -EmergencyAddressId ##########

.EXAMPLE
Retrieve inforation for all Emergency Addresses.
Get-ZoomPhoneSiteEmergencyAddress

.EXAMPLE
Retrieve detailed inforation for Emergency Addresses.
Get-ZoomPhoneSiteEmergencyAddress -Full

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listSettingTemplates

#>

function Get-ZoomPhoneSiteEmergencyAddress {

    [alias("Get-ZoomPhoneSiteEmergencyAddresses")]
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param ( 
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'Emergency_Address_Id')]
        [string[]]$EmergencyAddressId,

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

        [parameter(ParameterSetName="SpecificSite")]
        [parameter(ParameterSetName="AllData")]
        [switch]$Full = $False

    )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/emergency_addresses"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize $PageSize -NextPageToken $NextPageToken

            }
            "SelectedRecord" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -ObjectId $EmergencyAddressId

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