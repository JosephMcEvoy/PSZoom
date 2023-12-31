<#

.SYNOPSIS
Remove calling plan to a Zoom Phone User

.PARAMETER UserId
Unique number used to locate Zoom Phone User account.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.


.EXAMPLE
Remove-ZoomPhoneUserCallingPlan -UserId askywakler@thejedi.com

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/unassignCallingPlan

#>

function Remove-ZoomPhoneUserCallingPlan {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    [Alias("Remove-ZoomPhoneUserCallingPlans")]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'Emails', 'EmailAddress', 'EmailAddresses', 'Id', 'ids', 'user_id', 'user', 'users', 'userids')]
        [string[]]$UserId,

        [switch]$PassThru
    )
    


    process {
        foreach ($user in $UserId) {

            $CurrentLicense = Get-ZoomPhoneUser -UserId $user | Select-Object -ExpandProperty "calling_plans" | Select-Object -ExpandProperty "type"

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user/calling_plans/$CurrentLicense"


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


            if ($pscmdlet.ShouldProcess($Message, $User, "Remove calling plan")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}
