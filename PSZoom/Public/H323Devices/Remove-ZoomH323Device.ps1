<#

.SYNOPSIS
Delete a H.323/SIP device.

.DESCRIPTION
Delete a H.323/SIP device from an account.

.PARAMETER DeviceId
The device ID.

.EXAMPLE
Remove-ZoomH323Device -DeviceId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deviceDelete

#>

function Remove-ZoomH323Device {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'device_id')]
        [string]$DeviceId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/h323/devices/$DeviceId"

        if ($PSCmdlet.ShouldProcess($DeviceId, 'Delete H.323/SIP device')) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
