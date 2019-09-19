<#

.SYNOPSIS
Check if the user’s personal meeting room name exists.
.DESCRIPTION
Check if the user’s personal meeting room name exists.
.PARAMETER VanityName
Personal meeting room name.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
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
        [string[]]$VanityName,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api Key/Secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($name in $VanityName) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/vanity_name"
    
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('vanity_name', $VanityName)
            $Request.Query = $query.ToString()
        
    
            try {
                $response = Invoke-RestMethod -Uri $request.Uri -Headers $Headers -Method GET
            } catch {
                Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
            }
    
            Write-Output $response
        }
    }
}