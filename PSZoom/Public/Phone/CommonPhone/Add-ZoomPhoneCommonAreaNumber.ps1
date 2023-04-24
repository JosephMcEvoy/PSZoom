<#

.SYNOPSIS
Assign phone numbers to a common area.

.PARAMETER CommonAreaId
Common area ID or common area extension ID.

.PARAMETER Number
Phone number to be assigned to zoom user.
Use following command to get available phone numbers for Zoom instance.
Get-ZoomPhoneNumber

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Add-ZoomPhoneCommonAreaNumber -CommonAreaId "5se6dr7ft8ybu9nub" -PhoneNumber +18011011101

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/assignPhoneNumbersToCommonArea


#>

function Add-ZoomPhoneCommonAreaNumber {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string]$CommonAreaId,

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
        foreach ($CommonArea in $CommonAreaId) {

            if ($number -match "^[0-9]+") {

                $number = "{0}$number" -f '+'

            }

            $NumberInfo = Get-ZoomPhoneNumber -ErrorAction Stop | Where-object Number -eq $number 

            if (!($NumberInfo)) {

                Throw "Provided number was not found in the accounts's phone number list"

            }

            if ([bool]($NumberInfo.PSobject.Properties.name -match "assignee")) {

                Throw "Number is already assigned to another user"

            }

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$CommonArea/phone_numbers"
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

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


        if ($pscmdlet.ShouldProcess($Message, $CommonArea, "Adding $Number")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $CommonAreaId
        }
    }
}
