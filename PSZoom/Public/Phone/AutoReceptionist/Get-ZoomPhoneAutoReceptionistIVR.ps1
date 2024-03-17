<#

.SYNOPSIS
View specific Auto Receptionist interactive voice response (IVR) system.

.DESCRIPTION
View specific Auto Receptionist interactive voice response (IVR) system.

.PARAMETER AutoReceptionistId
The Auto Receptionist unique Id.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a Auto Receptionist's IVR.
Get-ZoomPhoneAutoReceptionistIVR -AutoReceptionistId "5x76c87v98b09ubvcmn6"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getAutoReceptionistIVR

#>

function Get-ZoomPhoneAutoReceptionistIVR {
    [CmdletBinding()]
    [Alias("Get-ZoomPhoneAutoReceptionistIVRs")]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'ids')]
        [string[]]$AutoReceptionistId
     )

    process {
        foreach ($id in $AutoReceptionistId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$id/ivr"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}