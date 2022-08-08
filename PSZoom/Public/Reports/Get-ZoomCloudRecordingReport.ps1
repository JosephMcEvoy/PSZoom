<#
.SYNOPSIS
Retrieve a report containing past Cloud Recording usage.

.DESCRIPTION
Retrieve a report containing past Cloud Recording usage.

.PARAMETER From
The start date for the monthly range for which you would like to retrieve recordings. The maximum range can be
a month. The month should fall within the past six months period from the date of query. Can only go back 6 months.

.PARAMETER To
The end date for the monthly range for which you would like to retrieve recordings. The maximum range can be a
month. The month should fall within the past six months period from the date of query.

.EXAMPLE
Retrieve an account's cloud recordings from April 5th 2020 through May 5th 2020.
Get-ZoomCloudRecordingReport -From 2020-05-01 -To 2020-05-05

.OUTPUTS
A hastable with the Zoom API response.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/reports/reportcloudrecording

#>

function Get-ZoomCloudRecordingReport {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]

        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$From,

        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$To
     )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/cloud_recording"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('From')) {
            $query.Add('from', $From)
        }

        if ($PSBoundParameters.ContainsKey('To')) {
            $query.Add('to', $To)
        }

        $Request.Query = $query.ToString()
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET

        Write-Output $response
    }
}