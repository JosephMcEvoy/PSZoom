<#

.SYNOPSIS
Add initial calling plan to a Zoom Phone User
                    
.PARAMETER LicenseType
License Type that is to applied to target phone account.
Use following command to get available license types for Zoom instance.
Get-ZoomPhoneCallingPlans

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Add-ZoomPhoneUserCallingPlans -UserId askywakler@thejedi.com -Type 200

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/assignCallingPlan

.LINK
https://developers.zoom.us/docs/api/rest/other-references/plans/

#>

function Add-ZoomPhoneUserCallingPlans {    
    [CmdletBinding(SupportsShouldProcess = $True)]
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

        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [Alias('License_Type')]
        [int]$LicenseType,

        [switch]$PassThru
    )
    


    process {
        foreach ($user in $UserId) {
            
            if (!(Get-ZoomUserSettings -UserId $user | Select-Object -ExpandProperty "feature" | Select-Object -ExpandProperty "zoom_phone")) {

                Update-ZoomUserSettings -UserId $user -ZoomPhone $True

            }

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user/calling_plans"
            $RequestBody = @{ }
            $ChosenLicense = @{ }


            $KeyValuePairs = @{
                'type'    = $LicenseType
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $ChosenLicense.Add($_, $KeyValuePairs.$_)
                }
            }

            $ChosenLicense = @($ChosenLicense)

            $RequestBody.Add("calling_plans", $ChosenLicense)

            $RequestBody = $RequestBody | ConvertTo-Json

            if ($pscmdlet.ShouldProcess) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
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
