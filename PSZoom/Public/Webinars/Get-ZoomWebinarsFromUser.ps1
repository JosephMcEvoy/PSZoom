<#

.SYNOPSIS
Use this API to list all the webinars that are scheduled by or on-behalf a 
user (Webinar host).

.DESCRIPTION
Zoom users with a webinar plan have access to creating and managing Webinars. Webinar allows a host to broadcast a 
Zoom meeting to up to 10,000 attendees. Use this API to list all the webinars that are scheduled by or on-behalf a 
user (Webinar host).

.PARAMETER UserId
The user ID or email address of the user. For user-level apps, pass `me` as the value for userId.

.PARAMETER Pagesize
The number of records returned within a single API call.

.PARAMETER PageNumber
The current page number of returned records.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
Zoom API response.

.LINK

.EXAMPLE
Get-ZoomWebinarsFromUser lskywalker@thejedi.com

.EXAMPLE
Export to CSV the participants from all webinars of a particular name from a given user. Does not take into account webinars with over 300 participants.
$Ids = ((Get-ZoomWebinarsFromUser myoda@thejedi.com -PageSize 300).webinars | where-object topic -eq 'Training').id
$Ids | foreach-object {
    (Get-ZoomWebinarParticipantsReport $_ -PageSize 300).participants
} | Export-Csv techtalkparticipants.csv

#>

function Get-ZoomWebinarsFromUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_id')]
        [string[]]$UserId,

        [ValidateRange(1,300)]
        [int]$PageSize = 30,

        [ValidateRange(1,300)]
        [int]$PageNumber = 1,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($id in $UserId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$id/webinars"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('page_size', $PageSize)
            $query.Add('page_number', $PageNumber)
            $request.Query = $query.ToString()
            $request.Query = $query.toString()
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers $headers -Body $RequestBody -Method GET
    
            Write-Output $response
        }
    }
}