<#

.SYNOPSIS
Check if the user’s personal meeting room name exists.

.DESCRIPTION
Check if the user’s personal meeting room name exists.

.PARAMETER VanityName
Personal meeting room name.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Get-ZoomPersonalMeetingRoomName 'Joes Room'

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/uservanityname

#>

function Get-ZoomPersonalMeetingRoomName {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('vanity_name', 'vanitynames')]
        [string[]]$VanityName
     )

    process {
        foreach ($name in $VanityName) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/vanity_name"
    
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('vanity_name', $VanityName)
            $Request.Query = $query.ToString()
        
    
           $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
    
            Write-Output $response
        }
    }
}