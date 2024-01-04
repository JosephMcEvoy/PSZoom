<#

.SYNOPSIS
Use this API to unassign a phone number from a Auto Receptionist.

.PARAMETER AutoReceptionistId
Use this API to unassign a phone number from a Auto Receptionist.
                    
.PARAMETER Number
Specific phone number to be unassigned from Auto Receptionist.
Use following command to get phone number assigned to Auto Receptionist.
Get-ZoomPhoneAutoReceptionist

.PARAMETER AllNumbers
Removes all phones numbers assigned to Auto Receptionist.

.OUTPUTS
No output. Can use Passthru switch to pass AutoReceptionistId to output.

.EXAMPLE
Remove-ZoomPhoneAutoReceptionistNumber -AutoReceptionistId "nc6xre5x76c6r-d" -PhoneNumber +18011011101

.EXAMPLE
Remove-ZoomPhoneAutoReceptionistNumber -AutoReceptionistId "nc6xre5x76c6r-d" -PhoneNumber 18011011101

.EXAMPLE
Remove-ZoomPhoneAutoReceptionistNumber -AutoReceptionistId "nc6xre5x76c6r-d" -AllNumbers

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/unassignAPhoneNumAutoReceptionist

#>

function Remove-ZoomPhoneAutoReceptionistNumber {    
    [CmdletBinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName="SingleNumber"
    )]

    Param(
        [Parameter(
            ParameterSetName="AllNumbers",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName="SingleNumber",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string[]]$AutoReceptionistId,

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
        $AutoReceptionistId | ForEach-Object {
            # Gather data about Common Area Phone
            $ZoomEntityInfo = Get-ZoomPhoneAutoReceptionist -AutoReceptionistId $_ -ErrorAction Stop

            # Grab a list of all numbers
            $VerifiedNumbersToBeRemoved = $ZoomEntityInfo | Select-Object -ExpandProperty phone_numbers -ErrorAction SilentlyContinue

            # If Parameter Set Name "Single Number" was chosen then the single number will be selected out of all the common area phone's numbers.
            switch ($PSCmdlet.ParameterSetName) {
                "SingleNumber" {
                    # Append "+" if not provided
                    if ($number -match "^[0-9]+") {
                        $number = "{0}$number" -f '+'
                    }
    
                    # Select only matching number
                    $VerifiedNumbersToBeRemoved = $VerifiedNumbersToBeRemoved | Where-Object number -eq $number

                    # If no match an error will be written
                    if ([string]::IsNullOrEmpty($VerifiedNumbersToBeRemoved)) {
                        Write-Error "The number provided is not assigned to user. Number: $number"
                        return
                    }
                }
            }

            foreach ($NumberTBR in $VerifiedNumbersToBeRemoved){
                $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$_/phone_numbers/$($NumberTBR.id)"
$Message =                 
@"

Method:  DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

                if ($pscmdlet.ShouldProcess($Message, $_, "Remove $NumberTBR")) {
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE
            
                    if (-not $PassThru) {
                        Write-Output $response
                    }
                }
            }
        }

        if ($PassThru) {
            Write-Output $AutoReceptionistId
        }
    }
}