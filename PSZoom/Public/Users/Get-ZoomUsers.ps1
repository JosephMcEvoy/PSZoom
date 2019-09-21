<#

.SYNOPSIS
List users on a Zoom account.

.DESCRIPTION
List users on a Zoom account.

.PARAMETER Status
User statuses:
Active - Users with an active status. This is the default status.
Inactive - Users with an inactive status.
Pending - Users with a pending status.

.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.

.PARAMETER PageNumber
The current page number of returned records. Default value is 1.

.PARAMETER FullApiResponse
The switch FullApiResponse will return the default Zoom API response.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/users

.EXAMPLE
Return the first page of users.
Get-ZoomUsers

.EXAMPLE
Return the first page of active users.
Get-ZoomUsers -Status active -PageSize 50

.EXAMPLE
Return active user emails.
(Get-ZoomUsers -PageSize 300 -pagenumber 3 -status active).Users.Email

#>

function Get-ZoomUsers {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('active', 'inactive', 'pending')]
        [string]$Status = 'active',

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_number')]
        [int]$PageNumber = 1,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('role_id')]
        [int]$RoleId,

        [switch]$FullApiResponse,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api key/secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]'https://api.zoom.us/v2/users/'
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('status', $Status)
        $query.Add('page_size', $PageSize)
        $query.Add('page_number', $PageNumber)

        if ($PSBoundParameters.ContainsKey('RoleId')) {
            $query.Add('role_id', $RoleId)
        }
        
        $Request.Query = $query.ToString()

        try {
            $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }

        if ($FullApiResponse) {
            Write-Output $response
        } else {
            Write-Output $response.Users
        }
    }
}