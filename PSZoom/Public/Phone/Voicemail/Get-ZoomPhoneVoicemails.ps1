<#

.SYNOPSIS
List account voicemails.

.DESCRIPTION
List voicemails for Zoom Phone account.

.PARAMETER VoicemailId
Unique Identifier of the voicemail.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
The full details of each voicemail.

.OUTPUTS
An array of Objects

.EXAMPLE
Get-ZoomPhoneVoicemails

.EXAMPLE
Get-ZoomPhoneVoicemails -PageSize 50

.EXAMPLE
Get-ZoomPhoneVoicemails -VoicemailId "abc123def456"

.EXAMPLE
Get-ZoomPhoneVoicemails -Full

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listAccountVoicemails

#>

function Get-ZoomPhoneVoicemails {

    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneVoicemail")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'voicemail_id')]
        [string[]]$VoicemailId,

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
        $baseURI = "https://api.$ZoomURI/v2/phone/voicemails"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "SelectedRecord" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $VoicemailId
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
