<#

.SYNOPSIS
List users on a Zoom account.

.DESCRIPTION
List users on a Zoom account. The Zoom API works similarly to browsing users on Zoom's website.
Because of this, API calls require a page number (default is 1) and page size (default is 30). 

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

.PARAMETER AllPages
Returns all pages. The default API response returns the first page of users. This loops through each page
and puts them together then returns all of the results. This only returns the inputted status (ie, only active,
inactive or pending).

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/users

.EXAMPLE
Return the first page of active users.
Get-ZoomUsers

.EXAMPLE
Return the first page of inactive users.
Get-ZoomUsers -Status inactive -PageSize 50

.EXAMPLE
Return active user emails.
(Get-ZoomUsers -PageSize 300 -pagenumber 3 -status active).Email

.EXAMPLE
Return all active users.
Get-ZoomUsers -AllPages

.EXAMPLE
Return all inactive users.
Get-ZoomUsers -Status Inactive -AllPages
#>

function Get-ZoomUsers {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'All'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'FullApiResponse'
        )]
        [ValidateSet('active', 'inactive', 'pending')]
        [string]$Status = 'active',
    
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'All'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'FullApiResponse'
        )]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'All'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'FullApiResponse'
        )]
        [Alias('page_number')]
        [int]$PageNumber = 1,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'All'
        )]
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'FullApiResponse'
        )]
        [Alias('role_id')]
        [int]$RoleId,

        [Parameter(
            ParameterSetName = 'FullApiResponse', 
            Mandatory = $True
        )]
        [switch]$FullApiResponse,

        [Parameter(
            ParameterSetName = 'All', 
            Mandatory = $True
        )]
        [switch]$AllPages,

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
        } elseif ($AllPages) {
            $params = @{}
            $allUsers = @()

            if ($PSBoundParameters.ContainsKey('Status')){
                $params.Add('status', $Status) 
            }

            if ($PSBoundParameters.ContainsKey('RoleId')){
                $params.Add('role_id', $RoleId) 
            }
            
            $pageCount = (Get-ZoomUsers -PageSize 300 @params -FullApiResponse).page_count

            while ($pageCount -gt 0){
                Write-Verbose 'Adding users from page $pageCount'
                $allusers += (Get-ZoomUsers -PageNumber $pageCount -PageSize 300 @params)
                $pageCount--
            }

            Write-Output $allUsers
        } else {
            Write-Output $response.Users
        }
    }
}