<#

.SYNOPSIS
Add members to a shared line group.

.DESCRIPTION
Add members to a shared line group. Members can be users or common area phones.

.PARAMETER SharedLineGroupId
The unique identifier of the shared line group.

.PARAMETER Members
An array of member objects. Each object should contain an 'id' property with the member's extension ID.

.PARAMETER MemberId
The extension ID of a single member to add to the shared line group.

.OUTPUTS
Outputs object

.EXAMPLE
Add a single member to a shared line group.
Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId "abc123" -MemberId "user123"

.EXAMPLE
Add multiple members to a shared line group.
$members = @(
    @{id = "user123"},
    @{id = "user456"}
)
Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId "abc123" -Members $members

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-shared-line-groups/addmemberstosharedlinegroup

#>

function Add-ZoomPhoneSharedLineGroupMembers {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('slgId', 'id', 'shared_line_group_id')]
        [string]$SharedLineGroupId,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = "MultipleMembers"
        )]
        [array]$Members,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = "SingleMember"
        )]
        [Alias('member_id', 'extension_id')]
        [string]$MemberId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/shared_line_groups/$SharedLineGroupId/members"

        $RequestBody = @{}

        if ($PSCmdlet.ParameterSetName -eq "SingleMember") {
            $Members = @(@{id = $MemberId})
        }

        $RequestBody.Add("members", $Members)

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $Message =
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $SharedLineGroupId, "Add Members")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
