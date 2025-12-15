<#

.SYNOPSIS
List external contacts on a Zoom Phone account.

.DESCRIPTION
List external contacts on a Zoom Phone account. External contacts are non-Zoom users that can be added to speed dials.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-external-contacts/listexternalcontacts

.EXAMPLE
Return a list of all external contacts.
Get-ZoomPhoneExternalContacts

.EXAMPLE
Get a page of external contacts.
Get-ZoomPhoneExternalContacts -PageSize 50 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomPhoneExternalContacts {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,

        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $baseURI = "https://api.$ZoomURI/v2/phone/external_contacts"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100
            }
        }

        Write-Output $AggregatedResponse
    }
}
