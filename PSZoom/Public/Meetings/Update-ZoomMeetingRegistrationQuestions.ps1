<#

.SYNOPSIS
Update registration questions that will be displayed to users while registering for a meeeting.
.DESCRIPTION
Update registration questions that will be displayed to users while registering for a meeeting.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER Questions
Array of registrant questions. Format of question object: 
Title <string>
Required <bool>
Valid Title fields are 'address', 'city', 'country', 'zip', 'state', 'phone', 'industry', 'org', 'job_title', 
'purchasing_time_frame', 'role_in_purchase_process', 'no_of_employees' and 'comments'.
Can also use New-RegistrantQuestion. Example:
$Questions = (New-RegistrantQuestion -Fieldname City - Required $True), (...)
.PARAMETER CustomQuestions
Array of custom registrant questions. Format:
Title <string>
Type <string>
Required <bool>
Answers <string array>
Valid types are 'short' and 'single'. Answers can only be used with 'short' type.
Can also use New-ZoomRegistrantCustomQuestion. Example:
$CustomQuestions = (New-ZoomRegistrantCustomQuestion -Title 'Favorite Color' -Type Short -Required $True -Answers 'Blue','Red','Green')
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
$params = @{
        MeetingId = $MeetingId
        ApiKey    = $ApiKey
        ApiSecret = $ApiSecret
        Questions = @(
            @{'FieldName' = 'Address'},
            @{'FieldName' = 'City'}
        )
        CustomQuestions  = @(
            @{
                'title' = 'Title'
                'type'  = 'single'
                'required' = $True
                'answers' = ('Mr','Ms')
            },
            @{
                'title' = 'Favorite Color'
                'type'  = 'short'
                'required' = $True
          }
        )
    }
    
$request = Update-ZoomMeetingRegistrationQuestions @params

#>

function Update-ZoomMeetingRegistrationQuestions {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [string]$MeetingId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('question')]
        [hashtable[]]$Questions,

        [Alias('custom_question', 'customquestion')]
        [hashtable[]]$CustomQuestions,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants/questions"
        $requestBody = @{}
        
        if ($PSBoundParameters.ContainsKey('Questions')) {
            $requestBody.Add('questions', $Questions)
        }
        
        if ($PSBoundParameters.ContainsKey('Questions')) {
            $requestBody.Add('customquestions', $CustomQuestions)
        }
        
        $requestBody = $requestBody | ConvertTo-Json
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers $headers -Body $requestBody -Method PATCH

        Write-Output $response
    }
}

<#
I would like to make these into classes that can be referenced from some sort
of classes file. Not sure how this works or if its feasible.

EXAMPLE
Update-ZoomRegistrationQuestions 123456789 -questions (New-ZoomRegistrantQuestion -FieldName 'Address'),(New-ZoomRegistrantQuestion -FieldName 'City')

EXAMPLE
Update-ZoomRegistrationQuestions 123456789 -customquestions (New-ZoomRegistrantCustomQuestion -title 'Title' -type 'single' -required $True -answers 'Mr','Ms'),`
(New-ZoomRegistrantCustomQuestion -title 'Favorite Color' -type 'single' -required $True -answers 'Blue','Red')

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
            throw 'Answers parameter requires type to be set to "short".'
        } else {
            $CustomQuestion.Add('answers', $Answers)
        }
    }

    Write-Output $CustomQuestion
}
#>