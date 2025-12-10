<#

.SYNOPSIS
List call queues on a Zoom account.

.DESCRIPTION
List call queues on a Zoom account.

.PARAMETER CallQueueId
Unique Identifier of the Call Queue.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listCallQueues

.EXAMPLE
Return a list of all the Call Queues.
Get-ZoomPhoneCallQueues

.EXAMPLE
Return a specific Call Queue by ID.
Get-ZoomPhoneCallQueues -CallQueueId "3vt4b7wtb79q4wvb"

.EXAMPLE
Get a page of call queues.
Get-ZoomPhoneCallQueues -PageSize 100 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomPhoneCallQueues {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneCallQueue")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'CallQueue_Id')]
        [string[]]$CallQueueId,

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
        $baseURI = "https://api.$ZoomURI/v2/phone/call_queues"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "SelectedRecord" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $CallQueueId
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100
            }
        }

        if ($Full) {
            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty ID
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name
        }

        Write-Output $AggregatedResponse
    }
}
