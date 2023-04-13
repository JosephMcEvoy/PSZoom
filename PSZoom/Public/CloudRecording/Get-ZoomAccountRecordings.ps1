<#

.SYNOPSIS
List Cloud Recordings available on an Account.

.DESCRIPTION
List Cloud Recordings available on an Account.

To access a password protected cloud recording, add an “access_token” parameter to the download URL and provide 
JWT as the value of the “access_token”.

Prerequisites:

A Pro or a higher paid plan with Cloud Recording option enabled.
Scopes: recording:read:admin or account:read:admin

If the scope recording:read:admin is used, the Account ID of the Account must be provided in the accountId path 
parameter to list recordings that belong to the Account. This scope only works for Sub Accounts.

To list recordings of a Master Account, the scope must be account:read:admin and the value of accountId should be me.

.PARAMETER AccountId
Unique identifier of the account.

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever 
the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER From
The start date for the monthly range for which you would like to retrieve recordings. The maximum range can be 
a month. The month should fall within the past six months period from the date of query.

.PARAMETER To
The end date for the monthly range for which you would like to retrieve recordings. The maximum range can be a 
month. The month should fall within the past six months period from the date of query.

.PARAMETER Trash
Boolean flag to get recordings from the trash. You cannot use the from an to parameters with this one.

.PARAMETER TrashType
The type of cloud recording that you would like to retrieve from the trash. Values can be meeting_recordings, recording_file and the default is meeting_recordings.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve an account's cloud recordings from April 5th 2020 through May 5th 2020.
Get-ZoomAccountRecordings -AccountId me -From 2020-05-01 -To 2020-05-05 -Pagesize 300

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/getaccountcloudrecording

#>

function Get-ZoomAccountRecordings {
    [CmdletBinding(DefaultParameterSetName = 'Default')]

    param (
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Trash')]
        [Alias('userids')]
        [string]$AccountId,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Trash')]
        [ValidateRange(1, 300)]
        [string]$PageSize = 300,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Trash')]
        [string]$NextPageToken,

        [Parameter(ParameterSetName = 'Default')]
        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$From,

        [Parameter(ParameterSetName = 'Default')]
        [ValidatePattern("([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))")]
        [string]$To,

        [Parameter(ParameterSetName = 'Trash')]
        [bool]$Trash = $false,

        [Parameter(ParameterSetName = 'Trash')]
        [ValidateSet('meeting_recordings','recording_file')]
        [Alias('trash_type')]
        [string]$TrashType = 'meeting_recordings'
    )


    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts/$AccountId/recordings"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('PageSize')) {
            $query.Add('page_size', $PageSize)
        }        
        
        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        } 

        if ($PSBoundParameters.ContainsKey('From')) {
            $query.Add('from', $From)
        } 

        if ($PSBoundParameters.ContainsKey('To')) {
            $query.Add('to', $To)
        } 

        if ($PSBoundParameters.ContainsKey('Trash')) {
            $query.Add('Trash', $Trash)
        } 
                
        if ($PSBoundParameters.ContainsKey('TrashType')) {
            $query.Add('trash_type', $trashtype)
        } 
        
        $Request.Query = $query.ToString()
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET

        Write-Output $response
    }
}
