<#

.SYNOPSIS
Get information about a specific SMS session.

.DESCRIPTION
Get information about a specific SMS session on a Zoom Phone account. An SMS session includes all messages between two parties.

.PARAMETER SessionId
The unique identifier of the SMS session.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-sms/getsmssession

.EXAMPLE
Get details of a specific SMS session.
Get-ZoomPhoneSMSSession -SessionId "abc123xyz"

.EXAMPLE
Get SMS session by ID from pipeline.
"abc123xyz" | Get-ZoomPhoneSMSSession

#>

function Get-ZoomPhoneSMSSession {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('session_id', 'id')]
        [string[]]$SessionId
     )

    process {
        foreach ($sid in $SessionId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/sms/sessions/$sid"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}
