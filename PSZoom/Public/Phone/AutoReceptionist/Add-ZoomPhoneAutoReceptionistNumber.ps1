<#

.SYNOPSIS
Assign phone numbers to a Auto Receptionist.

.PARAMETER AutoReceptionistId
Unique ID for the Auto Receptionist account.

.PARAMETER Number
Phone number to be assigned to zoom user.
Use following command to get available phone numbers for Zoom instance.
Get-ZoomPhoneNumber -Unassigned

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Add-ZoomPhoneAutoReceptionistNumber -AutoReceptionistId "5se6dr7ft8ybu9nub" -PhoneNumber +18011011101

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/assignPhoneNumbersAutoReceptionist

#>

function Add-ZoomPhoneAutoReceptionistNumber {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string]$AutoReceptionistId,

        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [Alias('Phone_Number')]
        [ValidateScript({(($_ -match "^\+[0-9]+$") -or ($_ -match "^[0-9]+$"))})]
        [string]$Number,

        [switch]$PassThru
    )
    
    process {
        foreach ($AutoReceptionist in $AutoReceptionistId) {

            if ($number -match "^[0-9]+") {
                $number = "{0}$number" -f '+'
            }

            $NumberInfo = Get-ZoomPhoneNumber -ErrorAction Stop | Where-object Number -eq $number 

            if (-not ($NumberInfo)) {
                Write-Error "Provided number was not found in the accounts's phone number list"
                Return
            }

            if ([bool]($NumberInfo.PSobject.Properties.name -match "assignee")) {
                Write-Error "Number is already assigned to another user"
                Return
            }

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist/phone_numbers"
            $RequestBody = @{ }
            $ChosenNumber = @{ }


            $KeyValuePairs = @{
                'id'      = $NumberInfo.id
                'number'  = $NumberInfo.number
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $ChosenNumber.Add($_, $KeyValuePairs.$_)
                }
            }

            $ChosenNumber = @($ChosenNumber)

            $RequestBody.Add("phone_numbers", $ChosenNumber)

            $RequestBody = $RequestBody | ConvertTo-Json

$Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


        if ($pscmdlet.ShouldProcess($Message, $AutoReceptionist, "Adding $Number")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
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