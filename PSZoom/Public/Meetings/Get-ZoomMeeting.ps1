<#

.SYNOPSIS
Retrieve the details of a meeting.
.DESCRIPTION
Retrieve the details of a meeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER OcurrenceId
The occurence ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomMeeting 123456789


#>

function Get-ZoomMeeting {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('ocurrence_id')]
        [string]$OcurrenceId,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials

        
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('OcurrenceId')) {
            $Query.Add('occurrence_id', $OcurrenceId)
            $Request.Query = $Query.toString()
        }        
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}
