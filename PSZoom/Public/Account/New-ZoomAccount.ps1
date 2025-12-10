<#

.SYNOPSIS
Create a sub account under the master account.

.DESCRIPTION
Create a sub account under the master account. Your account must be a master account and have this privilege to create sub accounts.

.PARAMETER FirstName
User's first name.

.PARAMETER LastName
User's last name.

.PARAMETER Email
User's email address.

.PARAMETER Password
User's password.

.PARAMETER Options
Account options object.

.EXAMPLE
New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password 'SecurePass123!'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountCreate

#>

function New-ZoomAccount {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Email,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [hashtable]$Options
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/accounts"

        $requestBody = @{
            'first_name' = $FirstName
            'last_name'  = $LastName
            'email'      = $Email
            'password'   = $Password
        }

        if ($PSBoundParameters.ContainsKey('Options')) {
            $requestBody['options'] = $Options
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
