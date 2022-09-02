<#

.SYNOPSIS
Invoke-ZoomRestMethod is used to make API calls to Zoom.

.DESCRIPTION
Invoke-ZoomRestMethod adds additional functionality to Invoke-RestMethod. It will automatically add the 
correct headers to the invocation as they pertain to Zoom, based on the API key and secret provided to the 
cmdlet. It also does some error handling, including retrying the call if there have been too many requests. 

Invoke-ZoomRestMethod can be used to make API calls that don't have a cmdlet associated with the call 
within PSZoom. See below.

.EXAMPLE
Get billing information.
$accountId = 123456789
$request = [System.UriBuilder]"https://api.zoom.us/v2/accounts/$accountId/billing"
Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

#>

function Invoke-ZoomRestMethod {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [string]$Method,
        [switch]$FollowRelLink,
        [int]$MaximumFollowRelLink,
        [string]$ResponseHeadersVariable,
        [string]$StatusCodeVariable,
        [switch]$UseBasicParsing,
        [uri]$Uri,
        $WebSession,
        [string]$SessionVariable,
        [switch]$AllowUnencryptedAuthentication,
        $Authentication,
        [psCredential]$Credential,
        [switch]$UseDefaultCredentials,
        [string]$CertificateThumbprint,
        [x509Certificate]$Certificate,
        [switch]$SkipCertificateCheck,
        $SslProtocol,
        [secureString]$Token = $PSZoomToken,
        [string]$UserAgent,
        [switch]$DisableKeepAlive,
        [int]$TimeoutSec,
        $Headers,
        [int]$MaximumRedirection,
        [int]$MaximumRetryCount,
        [int]$RetryIntervalSec,
        [uri]$Proxy,
        [psCredential]$ProxyCredential,
        [switch]$ProxyUseDefaultCredentials,
        [object]$Body,
        $Form,
        [string]$ContentType,
        [string]$TransferEncoding,
        [string]$InFile,
        [string]$OutFile,
        [switch]$PassThru,
        [switch]$Resume,
        [switch]$SkipHttpErrorCheck,
        [switch]$PreserveAuthorizationOnRedirect,
        [switch]$SkipHeaderValidation
    )
    
    $params = @{
        AllowUnencryptedAuthentication  = 'AllowUnencryptedAuthentication'
        Authentication                  = 'Authentication'
        Body                            = 'Body'
        Certificate                     = 'Certificate'
        CertificateThumbprint           = 'CertificateThumbprint'
        ContentType                     = 'ContentType'
        Credential                      = 'Credential'
        DisableKeepAlive                = 'DisableKeepAlive'
        FollowRelLink                   = 'FollowRelLink'
        Form                            = 'Form'
        Headers                         = 'Headers'
        InFile                          = 'InFile'
        MaximumFollowRelLink            = 'MaximumFollowRelLink'
        MaximumRedirection              = 'MaximumRedirection'
        MaximumRetryCount               = 'MaximumRetryCount'
        Method                          = 'Method'
        OutFile                         = 'OutFile'
        PassThru                        = 'PassThru'
        PreserveAuthorizationOnRedirect = 'PreserveAuthorizationOnRedirect'
        Proxy                           = 'Proxy'
        ProxyCredential                 = 'ProxyCredential'
        ProxyUseDefaultCredentials      = 'ProxyUseDefaultCredentials'
        ResponseHeadersVariable         = 'ResponseHeadersVariable'
        Resume                          = 'Resume'
        RetryIntervalSec                = 'RetryIntervalSec'
        SessionVariable                 = 'SessionVariable'
        SkipCertificateCheck            = 'SkipCertificateCheck'
        SkipHeaderValidatio             = 'SkipHeaderValidation'
        SkipHttpErrorCheck              = 'SkipHttpErrorCheck'
        SslProtocol                     = 'SslProtocol'
        StatusCodeVariable              = 'StatusCodeVariable'
        TimeoutSec                      = 'TimeoutSec'
        Token                           = 'Token'
        TransferEncoding                = 'TransferEncoding'
        Uri                             = 'Uri'
        UseBasicParsing                 = 'UseBasicParsing'
        UseDefaultCredentials           = 'UseDefaultCredentials'
        UserAgent                       = 'UserAgent'
        WebSession                      = 'WebSession'
    }

    function Remove-NonPsBoundParameters {
        param (
            $Obj,
            $Parameters = $PSBoundParameters
        )
  
        process {
            $NewObj = @{}
      
            foreach ($Key in $Obj.Keys) {
                if ($Parameters.ContainsKey($Obj.$Key) -or -not [string]::IsNullOrWhiteSpace($Obj.Key)) {
                    $Newobj.Add($Key, (get-variable $Obj.$Key).value)
                }
            }
      
            return $NewObj
        }
    }

    $params = Remove-NonPsBoundParameters($params)
    
    if (-not $Token) {
        Write-Host "No token found. Use Connect-PSZoom to get a global token then try running the command again.`n"
    } else {
        $params.Headers = (New-ZoomHeaders -Token $Token)
        Write-Verbose $params.Headers
    }


    if ([string]::IsNullOrEmpty($params.ContentType)) {
        $params.ContentType = 'application/json; charset=utf-8'
    }

    try {
        $response = Invoke-RestMethod @params
    }
    catch {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $errorStreamReader = [System.IO.StreamReader]::new($_.exception.Response.GetResponseStream())
            $errorDetails = ConvertFrom-Json ($errorStreamReader.ReadToEnd())
        }
        else {
            $errorDetails = ConvertFrom-Json $_.errorDetails -AsHashtable
        }

        $exception = $_.exception
        $targetObject = $_.targetObject
        $errorCode = $exception.message.split(':')[1] -replace '[^0-9]*'
        $category = switch ($errorCode) {
            300 { 'InvalidOperation' }
            400 { 'InvalidOperation' }
            401 { 'AuthenticationError' }
            404 { 'InvalidOperation' }
            409 { 'ResourceExists' }
            429 { 'LimitsExceeded' }
            Default { 'InvalidOperation' }
        }
        Write-Error -Message "$($exception.message) $($errorDetails.message)" -ErrorId $errorCode `
            -CategoryReason $errorDetails.message -TargetName $targetObject.requestUri `
            -CategoryActivity $targetObject.method -Category $category

        #Rate limiting logic
        if ($errorCode -eq 429) {
            # Max retry count: 5
            if ($script:RetryCount -lt 5) {
                $script:RetryCount++
                Write-Warning 'Error 429. Too many requests encountered. This is usually because of rate limiting. Retrying in 1 second.'
                Start-Sleep -Seconds 1
                Invoke-ZoomRestMethod @params
            }
        }
    }
    
    if ($response) {
        Write-Output $response
    }
}
