<#

.SYNOPSIS
List account recordings.

.DESCRIPTION
List phone recordings for Zoom Phone account.

.PARAMETER RecordingId
Unique Identifier of the recording.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
The full details of each recording.

.OUTPUTS
An array of Objects

.EXAMPLE
Get-ZoomPhoneRecordings

.EXAMPLE
Get-ZoomPhoneRecordings -PageSize 50

.EXAMPLE
Get-ZoomPhoneRecordings -RecordingId "abc123def456"

.EXAMPLE
Get-ZoomPhoneRecordings -Full

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listAccountRecordings

#>

function Get-ZoomPhoneRecordings {

    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneRecording")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'recording_id')]
        [string[]]$RecordingId,

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
        $baseURI = "https://api.$ZoomURI/v2/phone/recordings"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "SelectedRecord" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $RecordingId
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
