<#

.SYNOPSIS
List meetings for a user.
.DESCRIPTION
List meetings for a user.
.PARAMETER UserId
The user ID or email address.
.PARAMETER Type
Scheduled - All of the scheduled meetings.
Live - All of the live meetings.
Upcoming -  All of the upcoming meetings.
.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.
.PARAMETER PageNumber
The current page number of returned records. Default value is 1.

.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeetingsFromuser jsmith@lawfirm.com

#>


function Get-ZoomMeetingsFromUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string[]]$UserId,

        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('scheduled', 'live', 'upcoming')]
        [string]$Type = 'live',
        
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Alias('page_number')]
        [int]$PageNumber = 1
     )

    process {
        #This makes the Type parameter a bit friendlier with other cmdlets and Zoom API responses

        foreach ($id in $UserId) {

            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$id/meetings"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.add('type', $Type)
            $query.add('page_size', $PageSize)
            $query.add('page_number', $PageNumber)
            $request.Query = $query.ToString()
        
           $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
            
            Write-Output $response
        }
    }
}