<#

.SYNOPSIS
Update a meeting’s status.
.DESCRIPTION
Update a meeting’s status.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER Action
The update action. Available actions: end.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Update-MeetingStatus -MeetingId '123456789' -Action 'End'

#>

function Update-MeetingStatus {
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
            Position = 1
        )]
        [ValidateSet('end')]
        [string]$Action,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/status"

        if ($PSBoundParameters.ContainsKey('Action')) {
            $RequestBody = @{
                'action' = $Action
            }
        }

        try {
            $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Body $RequestBody -Method PUT
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        
        Write-Output $response
    }
}