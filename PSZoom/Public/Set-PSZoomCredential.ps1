<#
.SYNOPSIS
Creates or replaces a credential in the Credential Manager.
.DESCRIPTION
Creates or replaces a credential in the Credential Manager. All functions look in the credential store
for the resource 'PSZoom'. If found the ApiKey (Username) and the ApiSecret are used to invoke calls
to Zoom.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Set-PSZoomCredential -ApiKey '123ABCDEFGHIJK' -ApiSecret '45678LMNOPQRSTUVWXY'
#>

Function Set-PSZoomCredential {
    [CmdletBinding(
        ConfirmImpact = 'High',
        SupportsShouldProcess = $true
    )]
    [OutputType([Void])]

    Param (
        [Parameter(Mandatory = $True)]
        [string]$ApiKey,

        [Parameter(Mandatory = $True)]
        [string]$ApiSecret
    )

    Begin {
        try {
            [Void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
            
            $vault = New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop
        } catch {
            $_
            return
        }

        try {
            if ($vault.FindAllByResource('PSZoom').Count -ne 0) {
                if ($PSCmdlet.ShouldProcess($vault, 'Setting PSZoom API credentials.  There is already an Api credential present. Update values anyway?')) {
                    $vault.Add((New-Object -TypeName Windows.Security.Credentials.PasswordCredential -ArgumentList 'PSZoom', $ApiKey, $ApiSecret))
                }
            }
        } catch {
            try {
                $vault.Add((New-Object -TypeName Windows.Security.Credentials.PasswordCredential -ArgumentList 'PSZoom', $ApiKey, $ApiSecret))
            } catch {
                $_
                return
            }
        }
    }
}
#Set-PSZoomCredential -ApiKey 123 -ApiSecret 456
#(New-Object -TypeName Windows.Security.Credentials.PasswordVault -ErrorAction Stop).Retrieve('PSZoom', '1').Password