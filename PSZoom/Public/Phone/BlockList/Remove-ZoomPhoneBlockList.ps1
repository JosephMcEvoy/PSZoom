<#

.SYNOPSIS
Remove a Blocked List.

.PARAMETER BlockedListId
Remove a Blocked List.

.OUTPUTS
No output. Can use Passthru switch to pass BlockedListId to output.

.EXAMPLE
Remove-ZoomPhoneBlockList -BlockedListId "se5d7r6fcvtbyinj"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/deleteABlockedList

#>

function Remove-ZoomPhoneBlockList {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id','Ids','BlockedListIds')]
        [string[]]$BlockedListId,

        [switch]$PassThru
    )
    


    process {
        foreach ($BlockedList in $BlockedListId) {

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/blocked_list/$BlockedList"
            
$Message = 
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



            if ($pscmdlet.ShouldProcess($Message, $BlockedList, "Delete")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $BlockedListId
        }
    }
}
