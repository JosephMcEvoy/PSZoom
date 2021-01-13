<#

.SYNOPSIS
Get members for a group.

.DESCRIPTION
Get members for a group.
Prerequisite: Pro, Business, or Education account

.PARAMETER GroupId
The ID of the group as returned from "Get-ZoomGroups".

.PARAMETER PageSize
The number of records returned within a single API call. Default value is 30. Maximum value is 300.

.PARAMETER NextPageToken
Token to return next page of results when greater than PageSize as returned from this function.
(Zoom is depricating use of PageNumber so not going to implement that.)

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
Zoom response as an object.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/groups/groupmembers

.EXAMPLE
Return first 30 members of Group.
Get-ZoomGroupMembers -GroupId 24e50639b5bb4fab9c3c

.EXAMPLE
Return first 100 members of Group.
Get-ZoomGroupMembers -GroupId 24e50639b5bb4fab9c3c -PageSize 100

.EXAMPLE
Return the 50 members of Group from the specipide page of results.
Get-ZoomGroupMembers -GroupId 24e50639b5bb4fab9c3c -PageSize 50 -NextPageToken kwJNZhamVutyOKA7TZYmIWKbgkacbfU0UU2

#>

function Get-ZoomGroupMembers  {
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True, 
            Position = 0
        )]
        [Alias('group_id', 'group', 'id')]
        [string]$GroupId,

        [string]$ApiKey,
        
        [string]$ApiSecret,

        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Alias('next_page_token')]
        [String]$NextPageToken = ""
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/groups/$GroupId/members"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)
        $query.Add('next_page_token', $NextPageToken)

        $Request.Query = $query.ToString()

        try {
            $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        } finally {
            Write-Output $response
        }
    }
}