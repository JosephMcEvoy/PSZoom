<#

.SYNOPSIS
Add an available phone number to a Zoom User.
                    
.PARAMETER Number
Phone number to be assigned to zoom user.
Use following command to get available phone numbers for Zoom instance.
Get-ZoomPhoneNumbers

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Add-ZoomPhoneUserNumber -UserId askywakler@thejedi.com -PhoneNumber +18011011101

.EXAMPLE
Add-ZoomPhoneUserNumber -UserId askywakler@thejedi.com -PhoneNumber 18011011101

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/assignCallingPlan


#>

function Add-ZoomPhoneUserNumber {    
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
        [Alias('Phone_Number')]
        [ValidateScript({(($_ -match "^\+[0-9]+$") -or ($_ -match "^[0-9]+$"))})]
        [string]$Number,

        [switch]$PassThru
    )
    


    process {
        foreach ($user in $UserId) {

            if ($number -match "^[0-9]+") {

                $number = "{0}$number" -f '+'

            }

            $NumberInfo = Get-ZoomPhoneNumbers -ErrorAction Stop | Where-object Number -eq $number 

            if (!($NumberInfo)) {

                Throw "Provided number was not found in the accounts's phone number list"

            }

            if ([bool]($NumberInfo.PSobject.Properties.name -match "assignee")) {

                Throw "Number is already assigned to another user"

            }

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user/phone_numbers"
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
