<#

.SYNOPSIS
List users on a Zoom account who have been assigned Zoom Phone licenses.

.DESCRIPTION
List users on a Zoom account who have been assigned Zoom Phone licenses. 

.PARAMETER UserId
Unique Identifier of the user.

.PARAMETER SiteId
Unique Identifier of the site. This can be found in the ListPhoneSites API.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listphoneusers

.EXAMPLE
Return a list of all the zoom phone users.
Get-ZoomPhoneUsers

.EXAMPLE
Return the first page of Zoom phone users in Site. To find Site ID refer to Get-ZoomPhoneSites
Get-ZoomPhoneUsers -SiteId "3vt4b7wtb79q4wvb"

.EXAMPLE
Return Zoom phone sites.
Get-ZoomPhoneUsers -SiteId "3vt4b7wtb79q4wvb" -Full

.EXAMPLE
Get a page of zoom users with phone accounts.
Get-ZoomPhoneUsers -PageSize 100 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomPhoneUser {
    
    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneUsers")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'User_Id')]
        [string[]]$UserId,

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

        $BASEURI = "https://api.$ZoomURI/v2/phone/users"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize $PageSize -NextPageToken $NextPageToken

            }
            "SelectedRecord" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -ObjectId $UserId

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
