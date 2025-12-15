<#

.SYNOPSIS
Assign phone number to a Call Queue.

.PARAMETER CallQueueId
Unique ID for the Call Queue account.

.PARAMETER Number
Phone number to be assigned to Call Queue.
Use following command to get available phone numbers for Zoom instance.
Get-ZoomPhoneNumber -Unassigned

.PARAMETER PassThru
Return the CallQueueId after adding number.

.OUTPUTS
No output. Can use Passthru switch to pass CallQueueId to output.

.EXAMPLE
Add-ZoomPhoneCallQueueNumber -CallQueueId "5se6dr7ft8ybu9nub" -Number +18011011101

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/assignPhoneNumbersCallQueue

#>

function Add-ZoomPhoneCallQueueNumber {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'CallQueue_Id')]
        [string]$CallQueueId,

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
        if ($number -match "^[0-9]+") {
            $number = "{0}$number" -f '+'
        }

        $NumberInfo = Get-ZoomPhoneNumber -ErrorAction Stop | Where-object Number -eq $number

        if (-not ($NumberInfo)) {
            Write-Error "Provided number was not found in the account's phone number list"
            Return
        }

        if ([bool]($NumberInfo.PSobject.Properties.name -match "assignee")) {
            Write-Error "Number is already assigned to another user"
            Return
        }

        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/call_queues/$CallQueueId/phone_numbers"
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


        if ($pscmdlet.ShouldProcess($Message, $CallQueueId, "Adding $Number")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            if (-not $PassThru) {
                Write-Output $response
            }
        }

        if ($PassThru) {
            Write-Output $CallQueueId
        }
    }
}
