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

function New-Jwt {
    param (
        [Parameter(Mandatory = $True)]
        [ValidateSet('HS256', 'HS384', 'HS512')]
        [string]$Algorithm,
    
        $Type = $null,
    
        [Parameter(Mandatory = $True)]
        [string]$Issuer,
    
        [int]$ValidforSeconds = $null,
    
        [Parameter(Mandatory = $True)]
        [string]$SecretKey
    )

    Write-Verbose 'Generating JWT'
    $Exp = [int][double]::parse((Get-Date -Date $((Get-Date).addseconds($ValidforSeconds).ToUniversalTime()) -UFormat %s)) # Grab Unix Epoch Timestamp and add desired expiration
    
    $Header = @{ 
        alg = $Algorithm
        typ = $Type 
    }
    
    $Payload = @{ 
        iss = $Issuer
        exp = $Exp
    }
    
    $Headerjson = $Header | ConvertTo-Json -Compress
    $Payloadjson = $Payload | ConvertTo-Json -Compress
    
    $Headerjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Headerjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    $Payloadjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Payloadjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    
    $ToBeSigned = $Headerjsonbase64 + "." + $Payloadjsonbase64
    
    $SigningAlgorithm = switch ($Algorithm) {
        "HS256" { New-Object System.Security.Cryptography.HMACSHA256 }
        "HS384" { New-Object System.Security.Cryptography.HMACSHA384 }
        "HS512" { New-Object System.Security.Cryptography.HMACSHA512 }
    } 
    
    $SigningAlgorithm.Key = [System.Text.Encoding]::UTF8.GetBytes($SecretKey)
    $Signature = [Convert]::ToBase64String($SigningAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ToBeSigned))).Split('=')[0].Replace('+', '-').Replace('/', '_')
    
    $Token = "$Headerjsonbase64.$Payloadjsonbase64.$Signature"
    
    Write-Output $Token
}