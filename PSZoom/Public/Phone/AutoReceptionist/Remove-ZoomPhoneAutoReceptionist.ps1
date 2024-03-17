<#

.SYNOPSIS
Remove a non-primary auto receptionist.

.PARAMETER AutoReceptionistId
Remove a non-primary auto receptionist.

.OUTPUTS
No output. Can use Passthru switch to pass AutoReceptionistId to output.

.EXAMPLE
Remove-ZoomPhoneAutoReceptionist -AutoReceptionistId "se5d7r6fcvtbyinj"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteAutoReceptionist

#>

function Remove-ZoomPhoneAutoReceptionist {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id','Ids')]
        [string[]]$AutoReceptionistId,

        [switch]$PassThru
    )
    


    process {
        foreach ($AutoReceptionist in $AutoReceptionistId) {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist"

            $AutoReceptionistSiteID = Get-ZoomPhoneAutoReceptionist -AutoReceptionistId $AutoReceptionist | Select-Object -ExpandProperty site | Select-Object -ExpandProperty id

            $SitePrimaryAutoReceptionID = Get-ZoomPhoneSite -SiteId $AutoReceptionistSiteID | Select-Object -ExpandProperty main_auto_receptionist | Select-Object -ExpandProperty id

            if ($AutoReceptionist -eq $SitePrimaryAutoReceptionID) {

                # Returns prematurily from processing without attempting to execute delete attempt.
                Write-Error "`'$AutoReceptionist`' is currently the primary Auto Receptionist for site `'$AutoReceptionistSiteID`' and cannot be deleted."
                return
            }
            
$Message = 
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



            if ($pscmdlet.ShouldProcess($Message, $AutoReceptionist, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $AutoReceptionistId
        }
    }
}
