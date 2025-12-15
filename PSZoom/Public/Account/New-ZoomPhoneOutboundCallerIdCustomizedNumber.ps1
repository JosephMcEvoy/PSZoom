<#

.SYNOPSIS
Add phone numbers for an account's customized outbound caller ID.

.DESCRIPTION
Adds the account-level customized outbound caller ID phone numbers. Note that when multiple sites policy
is enabled, users cannot manage the account-level configuration. The system will throw an exception.

Prerequisites:
* A Business or Enterprise account
* A Zoom Phone license

Scopes: phone:write:admin
Granular Scopes: phone:write:customized_number:admin
Rate Limit Label: Light

.PARAMETER PhoneNumberIds
The phone number IDs to add as customized outbound caller ID numbers. Accepts an array of phone number IDs.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Add a single phone number ID to the customized outbound caller ID list.
New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds "abc123def456"

.EXAMPLE
Add multiple phone number IDs to the customized outbound caller ID list.
New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds @("abc123def456", "ghi789jkl012")

.EXAMPLE
Add phone number IDs via pipeline.
$ids = @("abc123def456", "ghi789jkl012")
$ids | New-ZoomPhoneOutboundCallerIdCustomizedNumber

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addOutboundCallerIdCustomizedNumbers

#>

function New-ZoomPhoneOutboundCallerIdCustomizedNumber {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('phone_number_ids', 'PhoneNumberId', 'Ids', 'Id')]
        [string[]]$PhoneNumberIds
    )

    begin {
        $AllPhoneNumberIds = [System.Collections.Generic.List[string]]::new()
    }

    process {
        foreach ($id in $PhoneNumberIds) {
            $AllPhoneNumberIds.Add($id)
        }
    }

    end {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/outbound_caller_id/customized_numbers"

        $RequestBody = @{
            'phone_number_ids' = @($AllPhoneNumberIds)
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("$($AllPhoneNumberIds.Count) phone number(s)", "Add customized outbound caller ID")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method POST

            Write-Output $response
        }
    }
}
