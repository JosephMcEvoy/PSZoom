<#

.SYNOPSIS
Generated Zoom headers.
.EXAMPLE
$Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
.OUTPUTS
Generic dictionary.

#>

function New-ZoomHeaders {
    param (
        [string]$ApiKey,
        [string]$ApiSecret
    )
    Write-Verbose 'Generating JWT'
    $Token = New-Jwt -Algorithm 'HS256' -type 'JWT' -Issuer $ApiKey -SecretKey $ApiSecret -ValidforSeconds 30

    Write-Verbose 'Generating Headers'
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('content-type' , 'application/json')
    $Headers.Add('authorization', 'bearer ' + $Token)

    Write-Output $Headers
}