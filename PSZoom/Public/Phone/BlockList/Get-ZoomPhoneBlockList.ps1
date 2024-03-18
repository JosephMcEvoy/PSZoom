<#

.SYNOPSIS
List Block Lists on a Zoom account.

.DESCRIPTION
List Block Lists on a Zoom account.

.PARAMETER BlockedLisIId
Unique Identifier of the Block Lists.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listBlockedList

.EXAMPLE
Return a list of all the Block Lists.
Get-ZoomPhoneBlockList

.EXAMPLE
Return the first page of Block Lists
Get-ZoomPhoneBlockList -BlockedLisIId "3vt4b7wtb79q4wvb"

.EXAMPLE
Get a page of Block Lists
Get-ZoomPhoneBlockList -PageSize 100 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomPhoneBlockList {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneBlockLists")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'BlockedLisIIds')]
        [string[]]$BlockedLisIId,

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
        $baseURI = "https://api.$ZoomURI/v2/phone/blocked_list"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "SelectedRecord" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $BlockedLisIId
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100
            }
        }
    
        if ($Full) {
            # No additional data with full so switching to normal query
            #$AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty ID
            #$AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name
        }

        Write-Output $AggregatedResponse 
    } 
}
