<#

.SYNOPSIS
Get a group under your account.
.DESCRIPTION
Get a group under your account.
Prerequisite: Pro, Business, or Education account
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
Zoom response as an object.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/group
.EXAMPLE
Get-ZoomSpecificGroup 24e50639b5bb4fab9c3c

#>

function Get-ZoomSpecificGroup  {
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group')]
        [string]$GroupId,

        [string]$ApiKey,
        
        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId"

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        } finally {
            Write-Output $Response
        }
    }
}