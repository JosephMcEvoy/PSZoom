<#

.SYNOPSIS
This isn't used for anything at the moment.

#>

function New-ZoomApiRestMethod {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Low')]
    param (
        [ValidateNotNullOrEmpty()]
        $Query,

        [ValidateNotNullOrEmpty()]
        $Body,

        [ValidateNotNullOrEmpty()]
        $Method,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]$FullUri
        
        if ($PSBoundParameters.ContainsKey('Query')) {
            $Request.Query = $Query.ToString()
        }

        $invokeParams = @{
            Headers = $Headers
            Method = $Method
            Uri = $Request.Uri
        }

        if ($PSBoundParameters.ContainsKey('Body')) {
            $invokeParams.Add('Body', $Body)
        }

        if ($PScmdlet.ShouldProcess) {
            try {
                $Response = Invoke-RestMethod @invokeParams
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            } finally {
                Write-Output $Response
            }
        }
    }
    
    end {}
}