<#

.SYNOPSIS
Update registration questions that will be displayed to users while registering for a meeeting.
.DESCRIPTION
Update registration questions that will be displayed to users while registering for a meeeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Update-ZoomRegistrationQuestions 123456789


#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Update-ZoomRegistrationQuestions {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            Position = 0
        )]
        [string]$MeetingId,

        [Alias('question')]
        [hashtable[]]$Questions,

        [Alias('custom_question')]
        [hashtable[]]$CustomQuestions,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }
    $RequestBody = @{}
    
    if ($PSBoundParameters.ContainsKey('Questions')) {
        $RequestBody.Add('questions', $Questions)
    }

    if ($PSBoundParameters.ContainsKey('Questions')) {
        $RequestBody.Add('customquestions', $CustomQuestions)
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants/questions"
    
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method PATCH
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}

function New-ZoomRegistrantQuestion {
    param (
        [Parameter(Mandatory = $True)]
        [ValidateSet('address', 'city', 'country', 'zip', 'state', 'phone', 'industry', 'org', 'job_title', 
        'purchasing_time_frame', 'role_in_purchase_process', 'no_of_employees', 'comments')]
        [Alias('field_name')]
        [string]$FieldName,

        [Parameter(Mandatory = $True)]
        [bool]$Required
    )

    $Question = @{
        'field_name' = $FieldName
        'required'   = $Required
    }

    Write-Output $Question
}

function New-ZoomRegistrantCustomQuestion {
    param (
        [Parameter(Mandatory = $True)]
        [string]$Title,

        [Parameter(Mandatory = $True)]
        [ValidateSet('short', 'single')]
        [string]$Type,

        [Parameter(Mandatory = $True)]
        [bool]$Required,

        [string[]]$Answers
    )

    $CustomQuestion = @{
        'title'       = $Title
        'type'        = $Type
        'required'    = $Required
    }

    if ($PSBoundParameters.ContainsKey('Answers')) {
        if ($Type -eq 'single') {
            throw 'Answers parameter rquires type to be set to "short".'
        } else {
            $CustomQuestion.Add('answers', $Answers)
        }
    }

    Write-Output $CustomQuestion
}