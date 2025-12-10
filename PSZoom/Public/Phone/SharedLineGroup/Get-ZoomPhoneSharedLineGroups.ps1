<#

.SYNOPSIS
List shared line groups on a Zoom Phone account.

.DESCRIPTION
List shared line groups on a Zoom Phone account. A shared line group allows Zoom Phone users to receive calls to a shared line and share this line with other members.

.PARAMETER SiteId
Unique identifier of the site. This can be found in the ListPhoneSites API.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-shared-line-groups/listsharedlinegroups

.EXAMPLE
Return a list of all shared line groups.
Get-ZoomPhoneSharedLineGroups

.EXAMPLE
Return shared line groups for a specific site.
Get-ZoomPhoneSharedLineGroups -SiteId "3vt4b7wtb79q4wvb"

.EXAMPLE
Get a page of shared line groups.
Get-ZoomPhoneSharedLineGroups -PageSize 50 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomPhoneSharedLineGroups {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            ParameterSetName="SpecificSite",
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('site_id')]
        [string]$SiteId,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,

        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [parameter(ParameterSetName="SpecificSite")]
        [parameter(ParameterSetName="AllData")]
        [switch]$Full = $False
     )

    process {
        $baseURI = "https://api.$ZoomURI/v2/phone/shared_line_groups"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100
            }

            "SpecificSite" {
                $QueryStatements = @{"site_id" = $SiteId}
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100 -AdditionalQueryStatements $QueryStatements
            }
        }

        if ($Full) {
            $AggregatedIDs = $AggregatedResponse | Select-Object -ExpandProperty ID
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun "Get-ZoomPhoneSharedLineGroup"
        }

        Write-Output $AggregatedResponse
    }
}
