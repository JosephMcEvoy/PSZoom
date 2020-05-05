<#

.SYNOPSIS
Get all the recordings from a user.

.DESCRIPTION
When a user records a meeting by choosing the Record to the Cloud option, the video, audio, 
and chat text are recorded in the Zoom cloud.

Use this API to list all Cloud Recordingsof a user. To access a password protected cloud recording, add an 
“access_token” parameter to the download URL and provide  as the value of the “access_token”. 

.PARAMETER UserId
The user ID or email address of the user. For user-level apps, pass `me` as the value for userId.

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken

The next page token is used to paginate through large result sets. A next page token will be returned whenever 
the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER MC
Query Metadata of Recording if an On-Premise Meeting Connector was used for the meeting.

.PARAMETER Trash
Query trash.
True: List recordings from trash.
False: Do not list recordings from the trash.
The  default value is `false`. If you set it to `true`, you can use the `TrashType` parameter to indicate the 
type of Cloud recording that you need to retrieve. 

.PARAMETER From
Start date in 'yyyy-mm-dd' format. (Within 6 month range).

.PARAMETER To
Start date in 'yyyy-mm-dd' format. (Within 6 month range).

.PARAMETER TrashType
The type of Cloud recording that you would like to retrieve from the trash.
NeetingRecordings: List all meeting recordings from the trash.  
RrecordingFile: List all individual recording files from the trash. 

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a meeting's cloud recording info.
Get-ZoomRecordings -UserId dvader@darkside.com

.EXAMPLE
Get all recording download URLs for a given user.
$recordings = Get-ZoomRecordings -UserId luke@thejedi.com -From 2020-01-01 -To 2020-05-04 | select meetings
$downloadURLs = $recordings.psobject.properties.value.recording_files.download_url

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/recordingslist

#>

function Get-ZoomRecordings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('userids')]
        [string[]]$UserId,

        [ValidateRange(1, 300)]
        [string]$PageSize = 30,

        [string]$NextPageToken,

        [bool]$MC = $False,

        [bool]$Trash = $False,

        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$From,

        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$To,

        [ValidateSet('meeting_recordings', 'recording_file')]
        [string]$TrashType = 'meeting_recordings',

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
        foreach ($user in $Userid) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user/recordings"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

            if ($PSBoundParameters.ContainsKey('PageSize')) {
                $query.Add('page_size', $PageSize)
            }        
            
            if ($PSBoundParameters.ContainsKey('NextPageToken')) {
                $query.Add('next_page_token', $NextPageToken)
            } 

            if ($PSBoundParameters.ContainsKey('MC')) {
                $query.Add('mc', $MC)
            } 

            if ($PSBoundParameters.ContainsKey('Trash')) {
                $query.Add('trash', $Trash)
            } 

            if ($PSBoundParameters.ContainsKey('From')) {
                $query.Add('from', $From)
            } 

            if ($PSBoundParameters.ContainsKey('To')) {
                $query.Add('to', $To)
            } 

            if ($PSBoundParameters.ContainsKey('TrashType')) {
                $query.Add('trash_type', $TrashType)
            } 
            
            $Request.Query = $query.ToString()

            try {
                $response = Invoke-RestMethod -Uri $request.Uri -Headers $Headers -Body $RequestBody -Method GET
            }
            catch {
                Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
            }
    
            Write-Output $response
        }
    }
}