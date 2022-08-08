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
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $tokenStr = ConvertFrom-SecureString -SecureString $Token -AsPlainText
    } else {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token)
        $tokenStr = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }

    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add('content-type' , 'application/json')
    $Headers.Add('authorization', 'bearer ' + $tokenStr)

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        # Clear plain string token.
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }

    Write-Output $Headers
}
