<#

.SYNOPSIS
List members of a call queue.

.DESCRIPTION
List members of a call queue.

.PARAMETER CallQueueId
Unique Identifier of the Call Queue.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listCallQueueMembers

.EXAMPLE
Return a list of all members in a Call Queue.
Get-ZoomPhoneCallQueueMembers -CallQueueId "3vt4b7wtb79q4wvb"

.EXAMPLE
Get a page of call queue members.
Get-ZoomPhoneCallQueueMembers -CallQueueId "3vt4b7wtb79q4wvb" -PageSize 50 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomPhoneCallQueueMembers {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'CallQueue_Id')]
        [string]$CallQueueId,

        [parameter()]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,

        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter()]
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $baseURI = "https://api.$ZoomURI/v2/phone/call_queues/$CallQueueId/members"

        if ($NextPageToken) {
            $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
        } else {
            $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize
        }

        Write-Output $AggregatedResponse
    }
}
