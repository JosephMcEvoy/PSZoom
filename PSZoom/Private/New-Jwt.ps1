<#

.DESCRIPTION
Encodes a JWT header, payload and signature.
.EXAMPLE
New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer $api_key -SecretKey $api_secret -ValidforSeconds 30
.EXAMPLE
$Token = New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer 123 -SecretKey 456 -ValidforSeconds 30
.LINK
https://marketplace.zoom.us/docs/guides/authorization/jwt/jwt-with-zoom

#>

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