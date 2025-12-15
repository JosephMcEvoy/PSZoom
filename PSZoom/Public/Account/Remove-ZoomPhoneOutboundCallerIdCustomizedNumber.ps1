<#

.SYNOPSIS
Delete phone numbers for an account's customized outbound caller ID.

.DESCRIPTION
Deletes the account-level customized outbound caller ID phone numbers. Note that when multiple sites policy
is enabled, users cannot manage the account-level configuration. The system will throw an exception.

Prerequisites:
* A Business or Enterprise account
* A Zoom Phone license.

Scopes: phone:write:admin
Granular Scopes: phone:delete:customized_number:admin
Rate Limit Label: Light

.PARAMETER CustomizeIds
The customization IDs to delete. Can be a single ID or an array of IDs.

.PARAMETER Passthru
Return the CustomizeIds after removal.

.OUTPUTS
No output on success. Can use Passthru switch to pass CustomizeIds to output.

.EXAMPLE
Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds "abc123"

Removes a single customized outbound caller ID phone number.

.EXAMPLE
Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds @("abc123", "def456", "ghi789")

Removes multiple customized outbound caller ID phone numbers.

.EXAMPLE
$idsToRemove = @("abc123", "def456")
Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds $idsToRemove -Passthru

Removes customized outbound caller ID phone numbers and returns the IDs.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteOutboundCallerIdCustomizedNumbers

#>

function Remove-ZoomPhoneOutboundCallerIdCustomizedNumber {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param(
        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('customize_ids', 'CustomizationIds', 'Ids', 'Id')]
        [string[]]$CustomizeIds,

        [switch]$Passthru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/outbound_caller_id/customized_numbers"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('CustomizeIds')) {
            foreach ($id in $CustomizeIds) {
                $Query.Add('customize_ids', $id)
            }
            $Request.Query = $Query.ToString()
        }

        $TargetDescription = if ($CustomizeIds) {
            "Customized Caller IDs: $($CustomizeIds -join ', ')"
        } else {
            "All Customized Caller IDs"
        }

        if ($PSCmdlet.ShouldProcess($TargetDescription, 'Delete')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            if ($Passthru) {
                Write-Output $CustomizeIds
            } else {
                Write-Output $response
            }
        }
    }
}
