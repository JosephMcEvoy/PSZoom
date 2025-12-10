<#

.SYNOPSIS
Update billing information for a sub account.

.DESCRIPTION
Update billing information for a sub account under the master account.

.PARAMETER AccountId
The account ID.

.PARAMETER FirstName
First name of the billing contact.

.PARAMETER LastName
Last name of the billing contact.

.PARAMETER Email
Email address of the billing contact.

.PARAMETER PhoneNumber
Phone number of the billing contact.

.PARAMETER Address
Address of the billing contact.

.PARAMETER City
City of the billing contact.

.PARAMETER State
State of the billing contact.

.PARAMETER Zip
Zip code of the billing contact.

.PARAMETER Country
Country of the billing contact.

.EXAMPLE
Update-ZoomAccountBilling -AccountId 'abc123' -FirstName 'John' -LastName 'Doe' -Email 'john@example.com'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountBillingUpdate

#>

function Update-ZoomAccountBilling {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'account_id')]
        [string]$AccountId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Email,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('phone_number')]
        [string]$PhoneNumber,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Address,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$City,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$State,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Zip,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Country
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/billing"

        $requestBody = @{}

        $params = @{
            'first_name'   = 'FirstName'
            'last_name'    = 'LastName'
            'email'        = 'Email'
            'phone_number' = 'PhoneNumber'
            'address'      = 'Address'
            'city'         = 'City'
            'state'        = 'State'
            'zip'          = 'Zip'
            'country'      = 'Country'
        }

        foreach ($key in $params.Keys) {
            $paramName = $params[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        if ($requestBody.Count -gt 0) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Patch
            Write-Output $response
        }
    }
}
