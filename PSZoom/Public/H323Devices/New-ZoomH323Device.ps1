<#

.SYNOPSIS
Create a H.323/SIP device.

.DESCRIPTION
Create a H.323/SIP device for an account.

.PARAMETER Name
The name of the device.

.PARAMETER Protocol
The protocol type. H.323 or SIP.

.PARAMETER Ip
The IP address of the device.

.PARAMETER Encryption
Encryption type. auto, yes, or no.

.EXAMPLE
New-ZoomH323Device -Name 'Conference Room A' -Protocol 'H.323' -Ip '192.168.1.100'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deviceCreate

#>

function New-ZoomH323Device {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [string]$Name,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('H.323', 'SIP')]
        [string]$Protocol,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Ip,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('auto', 'yes', 'no')]
        [string]$Encryption = 'auto'
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/h323/devices"

        $requestBody = @{
            'name'       = $Name
            'protocol'   = $Protocol
            'ip'         = $Ip
            'encryption' = $Encryption
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
