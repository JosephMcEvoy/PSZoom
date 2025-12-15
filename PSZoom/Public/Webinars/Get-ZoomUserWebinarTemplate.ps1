<#

.SYNOPSIS
List webinar templates for a user.

.DESCRIPTION
Display a list of a user's webinar templates. When you schedule a webinar, save the settings for that webinar as a template for scheduling future webinars. To use a template when scheduling a webinar, use the id value in this API response in the template_id field of the Create a webinar API.

Prerequisites:
* A Pro or a higher account with the Zoom Webinar plan.

.PARAMETER UserId
The user's ID. To get a user's ID, use the List users API. For user-level apps, pass the 'me' value instead of the user ID value.

.OUTPUTS
An object with the webinar templates information.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listWebinarTemplates

.EXAMPLE
Get-ZoomUserWebinarTemplate -UserId 'jsmith@example.com'

Returns all webinar templates for the specified user.

.EXAMPLE
Get-ZoomUserWebinarTemplate -UserId 'me'

Returns all webinar templates for the current user.

.EXAMPLE
'jsmith@example.com' | Get-ZoomUserWebinarTemplate

Returns all webinar templates for the specified user using pipeline input.

#>

function Get-ZoomUserWebinarTemplate {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_id', 'id', 'Email')]
        [string]$UserId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$UserId/webinar_templates"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
