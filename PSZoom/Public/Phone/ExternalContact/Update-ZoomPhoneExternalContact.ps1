<#

.SYNOPSIS
Update a specific external contact.

.DESCRIPTION
Update a specific external contact on a Zoom Phone account.

.PARAMETER ContactId
The unique identifier of the external contact.

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
No output. Can use Passthru switch to pass ContactId to output.

.EXAMPLE
Update external contact name.
Update-ZoomPhoneExternalContact -ContactId "abc123" -FirstName "John" -LastName "Smith"

.EXAMPLE
Update external contact phone number.
Update-ZoomPhoneExternalContact -ContactId "abc123" -PhoneNumber "+14155559999"

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-external-contacts/updateexternalcontact

#>

function Update-ZoomPhoneExternalContact {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'contact_id')]
        [string]$ContactId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('phone_number')]
        [string]$PhoneNumber,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Email,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Company,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('job_title')]
        [string]$JobTitle,

        [switch]$PassThru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/external_contacts/$ContactId"

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
            if ($PSBoundParameters.ContainsKey($_) -or $PSBoundParameters.ContainsKey(($_ -replace '_', ''))) {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $RequestBody.Add($_, $KeyValuePairs.$_)
                }
            }
        }

        if ($RequestBody.Count -eq 0) {
            throw 'Request must contain at least one External Contact change.'
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $Message =
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $ContactId, 'Update')) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

            if (-not $PassThru) {
                Write-Output $response
            }
        }

        if ($PassThru) {
            Write-Output $ContactId
        }
    }
}
