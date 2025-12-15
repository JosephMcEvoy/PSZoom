<#

.SYNOPSIS
List a webinar's polls.

.DESCRIPTION
Lists all the polls of a webinar.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:read:admin, webinar:read
Granular Scopes: webinar:read:list_polls, webinar:read:list_polls:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER Anonymous
Whether to query for polls with the Anonymous option enabled:
* $true - Query for polls with the Anonymous option enabled.
* $false - Do not query for polls with the Anonymous option enabled.

.OUTPUTS
An object with the webinar's polls.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPolls

.EXAMPLE
Get-ZoomWebinarPolls -WebinarId 123456789

.EXAMPLE
Get-ZoomWebinarPolls -WebinarId 123456789 -Anonymous $true

.EXAMPLE
123456789 | Get-ZoomWebinarPolls

#>

function Get-ZoomWebinarPolls {
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

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [bool]$Anonymous
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/polls"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('Anonymous')) {
            $query.Add('anonymous', $Anonymous.ToString().ToLower())
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
