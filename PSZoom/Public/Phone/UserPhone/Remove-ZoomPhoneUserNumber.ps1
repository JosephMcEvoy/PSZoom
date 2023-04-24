<#

.SYNOPSIS
Remove phone numbers from a user's zoom phone account.
                    
.PARAMETER Number
Specific phone number to be unassigned from zoom user.
Use following command to get a list of phone numbers assigned to a user.
Get-ZoomPhoneUser

.PARAMETER AllNumbers
Removes all phones numbers assigned to zoom user.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomPhoneUserNumber -UserId askywakler@thejedi.com -PhoneNumber +18011011101

.EXAMPLE
Remove-ZoomPhoneUserNumber -UserId askywakler@thejedi.com -PhoneNumber 18011011101

.EXAMPLE
Remove-ZoomPhoneUserNumber -UserId askywakler@thejedi.com -AllNumbers

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/UnassignPhoneNumber


#>

function Remove-ZoomPhoneUserNumber {    
    [CmdletBinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName="SingleNumber"
    )]
    Param(
        # -UserID
        [parameter(ParameterSetName="SingleNumber")]
        [parameter(ParameterSetName="AllNumbers")]
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Email', 'Emails', 'EmailAddress', 'EmailAddresses', 'Id', 'ids', 'user_id', 'user', 'users', 'userids')]
        [string[]]$UserId,


        # -Number
        [parameter(ParameterSetName="SingleNumber",
            Mandatory = $True, 
            Position = 1
        )]
        [Alias('Phone_Number')]
        [ValidateScript({(($_ -match "^\+[0-9]+$") -or ($_ -match "^[0-9]+$"))})]
        [string]$Number,


        # -AllNumbers
        [parameter(ParameterSetName="AllNumbers")]
        [switch]$AllNumbers,


        # -Passthru
        [parameter(ParameterSetName="SingleNumber")]
        [parameter(ParameterSetName="AllNumbers")]
        [switch]$PassThru
    )
    


    process {
        foreach ($user in $UserId) {

            $ZoomUserInfo = Get-ZoomPhoneUser -UserId $user -ErrorAction Stop

            $VerifiedNumbersToBeRemoved = $ZoomUserInfo | Select-Object -ExpandProperty phone_numbers
            
            if ($number) {

                if ($number -match "^[0-9]+") {

                    $number = "{0}$number" -f '+'
    
                }

                $VerifiedNumbersToBeRemoved = $ZoomUserInfo | Select-Object -ExpandProperty phone_numbers | Where-Object number -eq $number

                if ([string]::IsNullOrEmpty($VerifiedNumbersToBeRemoved)) {
                
                    throw "The number provided is not assigned to user! Number: $number"
    
                }

            }

            $VerifiedNumbersToBeRemoved | ForEach-Object {

                $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$user/phone_numbers/$($_.id)"

$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


            if ($pscmdlet.ShouldProcess($Message, $User, "Remove $number")) {
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE
            
                    if (-not $PassThru) {
                        Write-Output $response
                    }
                }

            }

        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}
