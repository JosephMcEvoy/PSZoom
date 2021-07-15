<#

.SYNOPSIS
Generate Zoom headers.

.PARAMETER ApiKey
The Zoom API key.

.PARAMETER ApiSecret
The Zoom API secret.

.EXAMPLE
$Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret

.EXAMPLE
$Headers = New-ZoomHeaders -Token $Token

.OUTPUTS
Generic dictionary.

#>

function New-ZoomHeaders {
    param (
        [string]$ApiKey,
        [string]$ApiSecret,
        [string]$Token
    )

    if (-not $Token) {
        $Token = New-ZoomApiToken -ApiKey $ApiKey -ApiSecret $ApiSecret -ValidforSeconds 30
    }

    Write-Verbose 'Generating Headers'
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('content-type' , 'application/json; charset=utf-8')
    $Headers.Add('authorization', 'bearer ' + $Token)

    Write-Output $Headers
}
