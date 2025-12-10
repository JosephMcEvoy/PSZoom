<#

.SYNOPSIS
List SMS message history for a Zoom Phone account.

.DESCRIPTION
List SMS message history for a Zoom Phone account. The history can be filtered by user, time range, and message type.

.PARAMETER UserId
The user ID or email address of the user. For user-level apps, pass the 'me' value.

.PARAMETER From
Start date and time in 'yyyy-MM-dd' or 'yyyy-MM-ddTHH:mm:ssZ' format. The date range defined by the from and to parameters should not exceed 30 days.

.PARAMETER To
End date and time in 'yyyy-MM-dd' or 'yyyy-MM-ddTHH:mm:ssZ' format. The date range defined by the from and to parameters should not exceed 30 days.

.PARAMETER MessageType
The type of SMS message. Allowed values: all, inbound, outbound. Default: all.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-sms/listsmshistory

.EXAMPLE
Get all SMS history for a user.
Get-ZoomPhoneSMSHistory -UserId "user@example.com"

.EXAMPLE
Get inbound SMS messages for a user in a date range.
Get-ZoomPhoneSMSHistory -UserId "user@example.com" -From "2024-01-01" -To "2024-01-31" -MessageType "inbound"

.EXAMPLE
Get outbound SMS messages with pagination.
Get-ZoomPhoneSMSHistory -UserId "user@example.com" -MessageType "outbound" -PageSize 50

#>

function Get-ZoomPhoneSMSHistory {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('user_id', 'email', 'id')]
        [string]$UserId,

        [Parameter()]
        [string]$From,

        [Parameter()]
        [string]$To,

        [Parameter()]
        [ValidateSet('all', 'inbound', 'outbound')]
        [Alias('message_type')]
        [string]$MessageType = 'all',

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,

        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $baseURI = "https://api.$ZoomURI/v2/phone/sms/history"

        $QueryStatements = @{}

        if ($PSBoundParameters.ContainsKey('UserId')) {
            $QueryStatements.Add('user_id', $UserId)
        }

        if ($PSBoundParameters.ContainsKey('From')) {
            $QueryStatements.Add('from', $From)
        }

        if ($PSBoundParameters.ContainsKey('To')) {
            $QueryStatements.Add('to', $To)
        }

        if ($PSBoundParameters.ContainsKey('MessageType')) {
            $QueryStatements.Add('message_type', $MessageType)
        }

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken -AdditionalQueryStatements $QueryStatements
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100 -AdditionalQueryStatements $QueryStatements
            }
        }

        Write-Output $AggregatedResponse
    }
}
