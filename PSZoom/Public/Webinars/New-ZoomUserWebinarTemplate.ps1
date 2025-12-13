<#

.SYNOPSIS
Create a webinar template from an existing webinar.

.DESCRIPTION
Create a webinar template from an existing webinar. When you schedule a webinar, you can save the settings for that webinar as a template for scheduling future webinars.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:create:webinar_template, webinar:create:webinar_template:admin
Rate Limit Label: LIGHT

.PARAMETER UserId
The user ID or email address of the user. To get a user's ID, use the Get-ZoomUsers API. For user-level apps, pass the 'me' value instead of the user ID value.

.PARAMETER WebinarId
The webinar ID of the existing webinar to use as the source for the template.

.PARAMETER Name
The name of the webinar template to create.

.PARAMETER SaveRecurrence
Whether to save the recurrence settings of the webinar. Default is $false.

.OUTPUTS
An object with the Zoom API response containing the created webinar template information.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/createWebinarTemplate

.EXAMPLE
New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId 123456789 -Name 'My Webinar Template'

Creates a new webinar template named 'My Webinar Template' from webinar ID 123456789 for the specified user.

.EXAMPLE
New-ZoomUserWebinarTemplate -UserId 'me' -WebinarId 987654321 -Name 'Recurring Template' -SaveRecurrence $true

Creates a webinar template from a recurring webinar and saves the recurrence settings.

.EXAMPLE
$params = @{
    UserId = 'user@example.com'
    WebinarId = 123456789
    Name = 'Weekly Training Template'
}
New-ZoomUserWebinarTemplate @params

Creates a webinar template using splatted parameters.

#>

function New-ZoomUserWebinarTemplate {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_id', 'id', 'Email')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('webinar_id')]
        [string]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('save_recurrence')]
        [bool]$SaveRecurrence = $false
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$UserId/webinar_templates"

        $RequestBody = @{
            'webinar_id' = $WebinarId
            'name'       = $Name
        }

        if ($PSBoundParameters.ContainsKey('SaveRecurrence')) {
            $RequestBody['save_recurrence'] = $SaveRecurrence
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("User $UserId", "Create webinar template '$Name' from webinar $WebinarId")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method POST

            Write-Output $response
        }
    }
}
