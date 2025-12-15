<#

.SYNOPSIS
Get webinar's token.

.DESCRIPTION
Retrieves a webinar's token to be used with SDKs. This token is used to embed a webinar
in your application via Web SDK or Native SDK.

Prerequisites:
* Pro or higher plan with the Webinar Add-on.

Scopes: webinar:read:admin, webinar:read
Granular Scopes: webinar:read:token, webinar:read:token:admin
Rate Limit Label: Light

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER Type
The token type. Valid values:
- closed_caption_token: Closed caption token for the third-party closed captioning integration.

.OUTPUTS
An object with the Zoom API response containing the webinar token.

.EXAMPLE
Get-ZoomWebinarToken -WebinarId 123456789

Gets the token for webinar with ID 123456789.

.EXAMPLE
Get-ZoomWebinarToken -WebinarId 123456789 -Type "closed_caption_token"

Gets the closed caption token for the webinar.

.EXAMPLE
123456789 | Get-ZoomWebinarToken

Gets the token via pipeline.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarToken

#>

function Get-ZoomWebinarToken {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [int64]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('closed_caption_token')]
        [Alias('token_type')]
        [string]$Type
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/token"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('Type')) {
            $query.Add('type', $Type)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
