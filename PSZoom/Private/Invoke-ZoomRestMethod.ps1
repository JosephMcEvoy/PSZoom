<#

.DESCRIPTION


#>

function Invoke-ZoomRestMethod {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        $Method,
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
        [secureString]$Token,
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

    try {
        $response = Invoke-RestMethod @params
    }
    catch {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $errorDetails = ConvertFrom-Json $_.errorDetails
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
            Write-Warning 'Error 429. Too many requests encountered. This is usually because of rate limiting. Retrying in 1 second.'
            Start-Sleep -Seconds 1
            Invoke-ZoomRestMethod @params
        }
    }
    
    if ($response) {
        Write-Output $response
    }
}