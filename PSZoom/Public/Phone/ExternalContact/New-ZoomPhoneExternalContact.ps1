<#

.SYNOPSIS
Create an external contact.

.DESCRIPTION
Create an external contact on a Zoom Phone account. External contacts are non-Zoom users that can be added to speed dials.

.PARAMETER FirstName
The first name of the external contact.

.PARAMETER LastName
The last name of the external contact.

.PARAMETER PhoneNumber
The phone number of the external contact in E.164 format (e.g., +14155551234).

.PARAMETER Email
The email address of the external contact.

.PARAMETER Company
The company name of the external contact.

.PARAMETER JobTitle
The job title of the external contact.

.OUTPUTS
Outputs object

.EXAMPLE
Create a new external contact.
New-ZoomPhoneExternalContact -FirstName "John" -LastName "Doe" -PhoneNumber "+14155551234"

.EXAMPLE
Create a new external contact with additional details.
New-ZoomPhoneExternalContact -FirstName "Jane" -LastName "Smith" -PhoneNumber "+14155555678" -Email "jane@example.com" -Company "Acme Corp" -JobTitle "Manager"

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-external-contacts/addexternalcontact

#>

function New-ZoomPhoneExternalContact {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(Mandatory = $True)]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(Mandatory = $True)]
        [Alias('phone_number')]
        [string]$PhoneNumber,

        [Parameter()]
        [string]$Email,

        [Parameter()]
        [string]$Company,

        [Parameter()]
        [Alias('job_title')]
        [string]$JobTitle
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/external_contacts"

        $RequestBody = @{}

        $KeyValuePairs = @{
            'first_name'   = $FirstName
            'last_name'    = $LastName
            'phone_number' = $PhoneNumber
            'email'        = $Email
            'company'      = $Company
            'job_title'    = $JobTitle
        }

        $KeyValuePairs.Keys | ForEach-Object {
            if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                $RequestBody.Add($_, $KeyValuePairs.$_)
            }
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $Message =
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, "$FirstName $LastName", "Create External Contact")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
