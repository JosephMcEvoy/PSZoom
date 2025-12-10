<#

.SYNOPSIS
Update a webinar registrant's status.

.DESCRIPTION
Update a webinar registrant's status. A host or co-host can approve or deny registrants.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER Action
Registrant status action. approve, cancel, deny.

.PARAMETER Registrants
Array of registrant IDs to update. Each should be a hashtable with 'id' and optionally 'email'.

.PARAMETER OccurrenceId
The webinar occurrence ID.

.EXAMPLE
Update-ZoomWebinarRegistrantStatus -WebinarId 123456789 -Action 'approve' -Registrants @(@{id='abc123'})

.EXAMPLE
Update-ZoomWebinarRegistrantStatus -WebinarId 123456789 -Action 'deny' -Registrants @(@{id='abc123'; email='john@company.com'})

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarRegistrantStatus

#>

function Update-ZoomWebinarRegistrantStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateSet('approve', 'cancel', 'deny')]
        [string]$Action,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [hashtable[]]$Registrants,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('occurrence_id')]
        [string]$OccurrenceId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants/status"

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('occurrence_id', $OccurrenceId)
            $Request.Query = $query.ToString()
        }

        $requestBody = @{
            'action'      = $Action
            'registrants' = $Registrants
        } | ConvertTo-Json -Depth 10

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method Put

        Write-Output $response
    }
}
