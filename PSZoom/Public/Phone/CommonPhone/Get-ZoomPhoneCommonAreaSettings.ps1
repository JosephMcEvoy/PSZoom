<#

.SYNOPSIS
Use this API to get common area settings.

.DESCRIPTION
Use this API to get common area settings.

.PARAMETER CommonAreaId
ID number[s] of common area phones to be queried.

.OUTPUTS
An array of Objects

.EXAMPLE
Get-ZoomPhoneCommonAreaSettings -CommonAreaId "4s5e6rc7tvbno"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/getCommonAreaSettings

#>



function Get-ZoomPhoneCommonAreaSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string[]]$CommonAreaId
    )

    process {
        $CommonAreaId | ForEach-Object {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$CommonAreaId/settings"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET | select-object -expandproperty "desk_phones"

            Write-Output $response
        }
    }
}