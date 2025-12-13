<#
.SYNOPSIS
Delete a webinar registrant.

.DESCRIPTION
Delete a webinar registrant.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:delete:registrant, webinar:delete:registrant:admin

Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar ID.

.PARAMETER RegistrantId
The registrant ID.

.PARAMETER OccurrenceId
The webinar occurrence ID.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId "abcdef123456"

Removes the specified registrant from the webinar.

.EXAMPLE
Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId "abcdef123456" -OccurrenceId "1648538400000"

Removes the specified registrant from a specific webinar occurrence.

.EXAMPLE
Get-ZoomWebinarRegistrants -WebinarId 123456789 | Where-Object { $_.email -eq "user@example.com" } | Remove-ZoomWebinarRegistrant -WebinarId 123456789

Removes a registrant by piping the registrant object.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deleteWebinarRegistrant

#>

function Remove-ZoomWebinarRegistrant {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Medium')]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('webinar_id', 'Id')]
        [int64]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('registrant_id')]
        [string]$RegistrantId,

        [Parameter(
            Mandatory = $False,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('occurrence_id')]
        [string]$OccurrenceId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants/$RegistrantId"

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('occurrence_id', $OccurrenceId)
            $Request.Query = $query.ToString()
        }

        if ($PSCmdlet.ShouldProcess("Registrant $RegistrantId from Webinar $WebinarId", "Remove")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            Write-Output $response
        }
    }
}
