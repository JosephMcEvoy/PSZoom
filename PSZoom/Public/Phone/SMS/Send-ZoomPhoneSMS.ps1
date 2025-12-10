<#

.SYNOPSIS
Send an SMS message from Zoom Phone.

.DESCRIPTION
Send an SMS message from a Zoom Phone number to one or more recipients.

.PARAMETER UserId
The user ID or email address of the user sending the SMS. For user-level apps, pass the 'me' value.

.PARAMETER Message
The SMS message content.

.PARAMETER ToPhoneNumbers
An array of recipient phone numbers in E.164 format (e.g., +14155551234).

.PARAMETER ToPhoneNumber
A single recipient phone number in E.164 format (e.g., +14155551234).

.PARAMETER FromPhoneNumber
The sender's phone number in E.164 format. If not provided, uses the user's default phone number.

.OUTPUTS
Outputs object

.EXAMPLE
Send an SMS to a single recipient.
Send-ZoomPhoneSMS -UserId "user@example.com" -Message "Hello from Zoom Phone!" -ToPhoneNumber "+14155551234"

.EXAMPLE
Send an SMS to multiple recipients.
Send-ZoomPhoneSMS -UserId "user@example.com" -Message "Team update" -ToPhoneNumbers @("+14155551234", "+14155555678")

.EXAMPLE
Send an SMS from a specific phone number.
Send-ZoomPhoneSMS -UserId "user@example.com" -Message "Hello!" -ToPhoneNumber "+14155551234" -FromPhoneNumber "+14155559999"

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-sms/sendsms

#>

function Send-ZoomPhoneSMS {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [Alias('user_id', 'email', 'id')]
        [string]$UserId,

        [Parameter(Mandatory = $True)]
        [string]$Message,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = "MultipleRecipients"
        )]
        [Alias('to_phone_numbers')]
        [string[]]$ToPhoneNumbers,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = "SingleRecipient"
        )]
        [Alias('to_phone_number')]
        [string]$ToPhoneNumber,

        [Parameter()]
        [Alias('from_phone_number')]
        [string]$FromPhoneNumber
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/sms"

        $RequestBody = @{
            'message' = $Message
        }

        if ($PSBoundParameters.ContainsKey('UserId')) {
            $RequestBody.Add('user_id', $UserId)
        }

        if ($PSCmdlet.ParameterSetName -eq "SingleRecipient") {
            $ToPhoneNumbers = @($ToPhoneNumber)
        }

        $RequestBody.Add('to_phone_numbers', $ToPhoneNumbers)

        if ($PSBoundParameters.ContainsKey('FromPhoneNumber')) {
            $RequestBody.Add('from_phone_number', $FromPhoneNumber)
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $Message =
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $UserId, "Send SMS")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
