<#

.SYNOPSIS
Get information about a specific external contact.

.DESCRIPTION
Get information about a specific external contact on a Zoom Phone account.

.PARAMETER ContactId
The unique identifier of the external contact.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-external-contacts/getanexternalcontact

.EXAMPLE
Get details of a specific external contact.
Get-ZoomPhoneExternalContact -ContactId "abc123xyz"

.EXAMPLE
Get external contact by ID from pipeline.
"abc123xyz" | Get-ZoomPhoneExternalContact

#>

function Get-ZoomPhoneExternalContact {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('contactId', 'id', 'contact_id')]
        [string[]]$ContactId
     )

    process {
        foreach ($cid in $ContactId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/external_contacts/$cid"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
