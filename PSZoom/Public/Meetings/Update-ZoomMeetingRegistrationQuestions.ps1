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

.OUTPUTS
.LINK
.EXAMPLE
$params = @{
        MeetingId = $MeetingId
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
        [hashtable[]]$CustomQuestions
    )


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
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

        Write-Output $response
    }
}