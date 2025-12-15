<#

.SYNOPSIS
List user call logs.

.DESCRIPTION
List call logs for a specific Zoom Phone user.

.PARAMETER UserId
The user ID or email address.

.PARAMETER PageSize
The number of records returned within a single API call (Min 1 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.OUTPUTS
An array of Objects

.EXAMPLE
Get-ZoomPhoneUserCallLogs -UserId "user@example.com"

.EXAMPLE
Get-ZoomPhoneUserCallLogs -UserId "abc123" -PageSize 50

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listUserCallLogs

#>

function Get-ZoomPhoneUserCallLogs {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('email', 'emailaddress', 'id', 'user_id', 'ids', 'userids', 'emails', 'emailaddresses')]
        [string[]]$UserId,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,

        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        foreach ($user in $UserId) {
            $baseURI = "https://api.$ZoomURI/v2/phone/users/$user/call_logs"

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
}
