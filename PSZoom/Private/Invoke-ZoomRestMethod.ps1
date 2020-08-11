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
        Method                          = 'Method'
        FollowRelLink                   = 'FollowRelLink'
        MaximumFollowRelLink            = 'MaximumFollowRelLink'
        ResponseHeadersVariable         = 'ResponseHeadersVariable'
        StatusCodeVariable              = 'StatusCodeVariable'
        UseBasicParsing                 = 'UseBasicParsing'
        Uri                             = 'Uri'
        WebSession                      = 'WebSession'
        SessionVariable                 = 'SessionVariable'
        AllowUnencryptedAuthentication  = 'AllowUnencryptedAuthentication'
        Authentication                  = 'Authentication'
        Credential                      = 'Credential'
        UseDefaultCredentials           = 'UseDefaultCredentials'
        CertificateThumbprint           = 'CertificateThumbprint'
        Certificate                     = 'Certificate'
        SkipCertificateCheck            = 'SkipCertificateCheck'
        SslProtocol                     = 'SslProtocol'
        Token                           = 'Token'
        UserAgent                       = 'UserAgent'
        DisableKeepAlive                = 'DisableKeepAlive'
        TimeoutSec                      = 'TimeoutSec'
        Headers                         = 'Headers'
        MaximumRedirection              = 'MaximumRedirection'
        MaximumRetryCount               = 'MaximumRetryCount'
        RetryIntervalSec                = 'RetryIntervalSec'
        Proxy                           = 'Proxy'
        ProxyCredential                 = 'ProxyCredential'
        ProxyUseDefaultCredentials      = 'ProxyUseDefaultCredentials'
        Body                            = 'Body'
        Form                            = 'Form'
        ContentType                     = 'ContentType'
        TransferEncoding                = 'TransferEncoding'
        InFile                          = 'InFile'
        OutFile                         = 'OutFile'
        PassThru                        = 'PassThru'
        Resume                          = 'Resume'
        SkipHttpErrorCheck              = 'SkipHttpErrorCheck'
        PreserveAuthorizationOnRedirect = 'PreserveAuthorizationOnRedirect'
        SkipHeaderValidatio             = 'SkipHeaderValidation'
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
    } catch {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $errorDetails = ConvertFrom-Json $_.errorDetails
        } else {
            $errorDetails = ConvertFrom-Json $_.errorDetails -AsHashtable
        }

        $exception = $_.exception
        $targetObject = $_.targetObject
        $errorCode = $exception.message.split(':')[1] -replace '[^0-9]*'
        $category = switch ($errorCode) {
            300     { 'InvalidOperation' }
            400     { 'InvalidOperation' }
            401     { 'AuthenticationError' }
            404     { 'InvalidOperation' }
            409     { 'ResourceExists' }
            429     { 'LimitsExceeded' }
            Default { 'InvalidOperation' }
        }
        Write-Error -Message "$($exception.message) $($errorDetails.message)" -ErrorId $errorCode `
        -CategoryReason $errorDetails.message -TargetName $targetObject.requestUri `
        -CategoryActivity $targetObject.method -Category $category

        #Rate limiting logic
        $retries = 0

        if ($errorCode -eq 429) {
            while ($retries -le 5) {
                Write-Warning 'Error 429. Too many requests encountered. This is usually because of rate limiting. Retrying in 1 second.'
                Start-Sleep -Seconds 1
                $retries++
                Invoke-ZoomRestMethod @params #This definitely won't work and will create an infinite loop...
            } else {
                Write-Error 'Error 429. Too many requests encountered. Cancelling request after 5 retries.'
            }

        }
    }

    Write-Output $response
}