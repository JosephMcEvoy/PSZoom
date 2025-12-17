<#

.SYNOPSIS
Get a routing form response.

.DESCRIPTION
Retrieve a specific routing form response by form ID and response ID.

Scopes: scheduler:read:admin
Granular Scopes: scheduler:read:form_response:admin

.PARAMETER FormId
The routing form ID.

.PARAMETER ResponseId
The routing form response ID.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/getSchedulerRoutingResponse

.EXAMPLE
Get-ZoomSchedulerRoutingResponse -FormId "abc123" -ResponseId "xyz789"

Retrieve a specific routing form response.

#>

function Get-ZoomSchedulerRoutingResponse {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('form_id')]
        [string]$FormId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('response_id')]
        [string]$ResponseId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/scheduler/routing/forms/$FormId/response/$ResponseId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
