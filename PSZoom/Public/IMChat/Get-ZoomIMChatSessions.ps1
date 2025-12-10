<#

.SYNOPSIS
Get IM chat sessions for a user.

.DESCRIPTION
Get IM chat sessions between the user and another user or channel.

.PARAMETER UserId
The user ID or email address.

.PARAMETER From
Start date for the query in yyyy-MM-dd format.

.PARAMETER To
End date for the query in yyyy-MM-dd format.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 30, max is 300.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets.

.EXAMPLE
Get-ZoomIMChatSessions -UserId 'user@company.com'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/imChatSessions

#>

function Get-ZoomIMChatSessions {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'user_id', 'email')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$From,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$To,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_size')]
        [ValidateRange(1, 300)]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/users/$UserId/chat/sessions"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('From')) {
            $query.Add('from', $From)
        }

        if ($PSBoundParameters.ContainsKey('To')) {
            $query.Add('to', $To)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
