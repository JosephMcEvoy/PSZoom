<#

.SYNOPSIS
Remove zoom phone common area account

.PARAMETER CommonAreaId
Unique number used to locate Common Area Phone account.

.OUTPUTS
No output. Can use Passthru switch to pass CommonAreaID to output.

.EXAMPLE
Remove-ZoomPhoneCommonArea -CommonAreaId "se5d7r6fcvtbyinj"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteCommonArea

#>

function Remove-ZoomPhoneCommonArea {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id')]
        [string[]]$CommonAreaId,

        [switch]$PassThru
    )
    


    process {
        foreach ($CommonArea in $CommonAreaId) {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$CommonArea"


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
"@



        if ($pscmdlet.ShouldProcess($Message, $CommonAreaId, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $CommonAreaID
        }
    }
}
