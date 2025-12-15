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
User's password as a SecureString. Use ConvertTo-SecureString or Read-Host -AsSecureString to create.

.PARAMETER Options
Account options object.

.PARAMETER AccountName
Sub-account name.

.PARAMETER VanityUrl
Vanity URL for the sub-account.

.EXAMPLE
$password = Read-Host -AsSecureString -Prompt 'Enter password'
New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $password

.EXAMPLE
$securePassword = ConvertTo-SecureString 'SecurePass123!' -AsPlainText -Force
New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $securePassword

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountCreate

#>

function New-ZoomAccount {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Medium')]
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
        [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ErrorMessage = "'{0}' is not a valid email address format.")]
        [string]$Email,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [SecureString]$Password,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [hashtable]$Options,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('account_name')]
        [string]$AccountName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('vanity_url')]
        [string]$VanityUrl
    )

    process {
        if ($PSCmdlet.ShouldProcess($Email, 'Create Zoom sub-account')) {
            $Uri = "https://api.$ZoomURI/v2/accounts"

            # Convert SecureString to plain text for API call
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
            try {
                $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

                $requestBody = @{
                    'first_name' = $FirstName
                    'last_name'  = $LastName
                    'email'      = $Email
                    'password'   = $PlainPassword
                }

                if ($PSBoundParameters.ContainsKey('Options')) {
                    $requestBody['options'] = $Options
                }

                if ($PSBoundParameters.ContainsKey('AccountName')) {
                    $requestBody['account_name'] = $AccountName
                }

                if ($PSBoundParameters.ContainsKey('VanityUrl')) {
                    $requestBody['vanity_url'] = $VanityUrl
                }

                $requestBody = ConvertTo-Json $requestBody -Depth 10
                $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

                Write-Output $response
            }
            finally {
                # Clear the plain text password from memory
                if ($BSTR -ne [IntPtr]::Zero) {
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                }
            }
        }
    }
}
