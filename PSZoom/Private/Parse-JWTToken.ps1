function Parse-JWTtoken {
    <#
    .DESCRIPTION
    Decodes a JWT token. This was taken from link below. Thanks to Vasil Michev.
    .LINK
    https://www.michev.info/Blog/Post/2140/decode-jwt-access-and-id-tokens-via-powershell
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$Token
    )

    #Validate as per https://tools.ietf.org/html/rfc7519
    #Access and ID tokens are fine, Refresh tokens will not work
    if (-not $Token.Contains(".") -or -not $Token.StartsWith("eyJ")) {
        Write-Error "Invalid token" -ErrorAction Stop
    }
 
    #Header
    $tokenheader = $Token.Split(".")[0].Replace('-', '+').Replace('_', '/')

    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenheader.Length % 4) {
        Write-Verbose "Invalid length for a Base-64 char array or string, adding ="
        $tokenheader += "="
    }

    Write-Verbose "Base64 encoded (padded) header: $tokenheader"

    #Convert from Base64 encoded string to PSObject all at once
    Write-Verbose "Decoded header:"
    $header = ([System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | convertfrom-json)
 
    #Payload
    $tokenPayload = $Token.Split(".")[1].Replace('-', '+').Replace('_', '/')

    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenPayload.Length % 4) {
        Write-Verbose "Invalid length for a Base-64 char array or string, adding ="
        $tokenPayload += "="
    }
    
    Write-Verbose "Base64 encoded (padded) payoad: $tokenPayload"

    $tokenByteArray = [System.Convert]::FromBase64String($tokenPayload)


    $tokenArray = ([System.Text.Encoding]::ASCII.GetString($tokenByteArray) | ConvertFrom-Json)

    #Converts $header and $tokenArray from PSCustomObject to Hashtable so they can be added together.
    #I would like to use -AsHashTable in convertfrom-json. This works in pwsh 6 but for some reason Appveyor isnt running tests in pwsh 6.
    $headerAsHash = @{}
    $tokenArrayAsHash = @{}
    $header.psobject.properties | ForEach-Object { $headerAsHash[$_.Name] = $_.Value }
    $tokenArray.psobject.properties | ForEach-Object { $tokenArrayAsHash[$_.Name] = $_.Value }
    $output = $headerAsHash + $tokenArrayAsHash

    Write-Output $output
}