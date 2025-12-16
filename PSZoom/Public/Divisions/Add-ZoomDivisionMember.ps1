<#

.SYNOPSIS
Add users to a division.

.DESCRIPTION
Adds one or more users to a specific division.

.PARAMETER DivisionId
The division ID.

.PARAMETER UserIds
An array of user IDs to add to the division.

.EXAMPLE
Add-ZoomDivisionMember -DivisionId "abc123" -UserIds "user1"

.EXAMPLE
Add-ZoomDivisionMember -DivisionId "abc123" -UserIds @("user1", "user2", "user3")

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/Adduserstodivision

#>

function Add-ZoomDivisionMember {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('division_id', 'id')]
        [string]$DivisionId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('user_ids', 'members')]
        [string[]]$UserIds
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/divisions/$DivisionId/users"

        $body = @{
            user_ids = $UserIds
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Post

        if ($null -eq $response) {
            Write-Output $true
        } else {
            Write-Output $response
        }
    }
}
