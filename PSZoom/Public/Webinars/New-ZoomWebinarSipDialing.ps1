<#
.SYNOPSIS
Get a webinar's SIP URI with passcode.

.DESCRIPTION
Get a webinar's SIP URI. The URI consists of the webinar ID, an optional user-supplied passcode, and participant identifier code. The API return data also includes additional fields to indicate whether the API caller has a valid Cloud Room Connector subscription, the participant identifier code from the URI, and the SIP URI validity period in seconds.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:sip_dialing, webinar:write:admin:sip_dialing

Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID. When storing this value in your database, store it as a long format integer and not an integer. Webinar IDs can exceed 10 digits.

.PARAMETER Passcode
If customers want a passcode to be embedded in the SIP URI dial string, they must supply the passcode. Zoom will not validate the passcode.

.OUTPUTS
An object with the Zoom API response containing SIP URI details.

.EXAMPLE
New-ZoomWebinarSipDialing -WebinarId 1234567890

Gets the SIP URI for the specified webinar without an embedded passcode.

.EXAMPLE
New-ZoomWebinarSipDialing -WebinarId 1234567890 -Passcode "MyPasscode123"

Gets the SIP URI for the specified webinar with the passcode embedded in the dial string.

.EXAMPLE
1234567890 | New-ZoomWebinarSipDialing

Gets the SIP URI for the webinar using pipeline input.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarSIPUriWithPasscode

#>

function New-ZoomWebinarSipDialing {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('webinar_id', 'Id')]
        [long]$WebinarId,

        [Parameter(
            Mandatory = $False,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Passcode
    )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/sip_dialing"

        # Build request body
        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('Passcode')) {
            $requestBody.Add('passcode', $Passcode)
        }

        $requestBody = $requestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", "Get SIP URI")) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
