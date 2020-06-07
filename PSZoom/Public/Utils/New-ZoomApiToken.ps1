<#

.SYNOPSIS
Generated Zoom API access token.
.EXAMPLE
$Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret
.OUTPUTS
Zoom API access token as string

#>

function New-ZoomApiToken {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter()]
        [string]$ApiKey,

        [Parameter()]
        [string]$ApiSecret,

        [Parameter()]
        [int]$ValidforSeconds = 30
    )

    $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
    $Token = New-Jwt -Algorithm 'HS256' -type 'JWT' -Issuer $Credentials.ApiKey -SecretKey $Credentials.ApiSecret -ValidforSeconds $ValidforSeconds
    Write-Output $Token
}
