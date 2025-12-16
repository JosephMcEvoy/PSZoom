<#

.SYNOPSIS
Delete a division.

.DESCRIPTION
Deletes an existing division under the account.

.PARAMETER DivisionId
The division ID.

.EXAMPLE
Remove-ZoomDivision -DivisionId "abc123"

.EXAMPLE
"abc123" | Remove-ZoomDivision -Confirm:$false

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/Deleteadivision

#>

function Remove-ZoomDivision {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('division_id', 'id')]
        [string]$DivisionId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/divisions/$DivisionId"

        if ($PSCmdlet.ShouldProcess($DivisionId, 'Remove division')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Delete

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
