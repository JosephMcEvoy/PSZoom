<#
.SYNOPSIS
Update the owner of a Zoom account.

.DESCRIPTION
Change the owner of an account. This API is used to transfer account ownership from one user to another.

.PARAMETER AccountId
The account ID.

.PARAMETER Email
The email address of the new account owner.

.EXAMPLE
Update-ZoomAccountOwner -AccountId "abc123" -Email "newowner@example.com"

.EXAMPLE
"abc123" | Update-ZoomAccountOwner -Email "newowner@example.com"

.OUTPUTS
Returns $true if the update was successful.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateAccountOwner

#>
function Update-ZoomAccountOwner {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('account_id', 'id')]
        [string]$AccountId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [string]$Email
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/owner"

        $requestBody = @{
            email = $Email
        }

        if ($PSCmdlet.ShouldProcess($AccountId, "Update account owner to $Email")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Put -Body $requestBody

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
