<#

.SYNOPSIS
Verify if a user’s email is registered with Zoom..
.DESCRIPTION
Verify if a user’s email is registered with Zoom..
.PARAMETER Email
The email address to be verified.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomUserEmailStatus jsmith@lawfirm.com
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/useremail
.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomUserEmailStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True
        )]
        [Alias('EmailAddress', 'Id', 'UserId')]
        [string]$Email,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/email"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $Query.Add('email', $Email)
        $Request.Query = $Query.ToString()

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}