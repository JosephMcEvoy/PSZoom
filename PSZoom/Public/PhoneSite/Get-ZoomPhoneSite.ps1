<#

.SYNOPSIS
View specific site information in the Zoom Phone account.

.DESCRIPTION
View specific site information in the Zoom Phone account.

.PARAMETER SiteId
The Site Id to be queried.

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
Retrieve a site's settings templates.
Get-ZoomPhoneSite -SiteId ##########

.EXAMPLE
Retrieve inforation for all sites.
Get-ZoomPhoneSite

.EXAMPLE
Retrieve detailed inforation for all sites.
Get-ZoomPhoneSite -Full

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listPhoneSites

#>


function Get-ZoomPhoneSite {

    [alias("Get-ZoomPhoneSites")]
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
        [switch]$Full = $False

    )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/sites"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize $PageSize -NextPageToken $NextPageToken

            }
            "SelectedRecord" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -ObjectId $siteId

            }
            "AllData" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize 100

            }
        }

        if ($Full) {

            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty Id
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name

        }

        Write-Output $AggregatedResponse

    }	
}