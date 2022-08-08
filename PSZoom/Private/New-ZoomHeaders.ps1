<#

.SYNOPSIS
Generate Zoom headers.

.PARAMETER ApiKey
The Zoom API key.

.PARAMETER ApiSecret
The Zoom API secret.

.EXAMPLE
$Headers = New-ZoomHeaders -Token $Token

.OUTPUTS
Generic dictionary.

#>

function New-ZoomHeaders {
    param (
        [Parameter(Mandatory = $True)]
        [securestring]$Token
    )
    
    Write-Verbose 'Generating Headers'
    $tokenStr = ConvertFrom-SecureString -SecureString $Token -AsPlainText
    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('content-type' , 'application/json')
    $Headers.Add('authorization', 'bearer ' + $tokenStr)

    Write-Verbose $Headers
    Write-Output $Headers
}
