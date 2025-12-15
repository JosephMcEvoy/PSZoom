<#

.SYNOPSIS
Update a H.323/SIP device.

.DESCRIPTION
Update a H.323/SIP device on an account.

.PARAMETER DeviceId
The device ID.

.PARAMETER Name
The name of the device.

.PARAMETER Protocol
The protocol type. H.323 or SIP.

.PARAMETER Ip
The IP address of the device.

.PARAMETER Encryption
Encryption type. auto, yes, or no.

.EXAMPLE
Update-ZoomH323Device -DeviceId 'abc123' -Name 'Conference Room B'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deviceUpdate

#>

function Update-ZoomH323Device {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'device_id')]
        [string]$DeviceId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('H.323', 'SIP')]
        [string]$Protocol,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Ip,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('auto', 'yes', 'no')]
        [string]$Encryption
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/h323/devices/$DeviceId"

        $requestBody = @{}

        $params = @{
            'name'       = 'Name'
            'protocol'   = 'Protocol'
            'ip'         = 'Ip'
            'encryption' = 'Encryption'
        }

        foreach ($key in $params.Keys) {
            $paramName = $params[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        if ($requestBody.Count -gt 0) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Patch
            Write-Output $response
        }
    }
}
