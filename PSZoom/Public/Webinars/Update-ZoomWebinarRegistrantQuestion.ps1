<#

.SYNOPSIS
Update a webinar's registration questions.

.DESCRIPTION
Update a webinar's registration questions. Use this API to update the registration questions and custom questions for a webinar.

Prerequisites:
* The account must have a Webinar plan.
* Registration must be required for the webinar.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:update:registrant_question, webinar:update:registrant_question:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER Questions
An array of standard question hashtables. Each hashtable should contain:
- field_name: The field name of the question (e.g., 'address', 'city', 'country', 'zip', 'state', 'phone', 'industry', 'org', 'job_title', 'purchasing_time_frame', 'role_in_purchase_process', 'no_of_employees', 'comments')
- required: Whether the question is required (true/false)

.PARAMETER CustomQuestions
An array of custom question hashtables. Each hashtable should contain:
- title: The custom question title (required)
- type: The question type - 'short' or 'single' (required)
- required: Whether the question is required
- answers: An array of answer options (required for 'single' type questions)

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateWebinarRegistrantQuestions

.EXAMPLE
$questions = @(
    @{
        field_name = 'address'
        required = $true
    },
    @{
        field_name = 'city'
        required = $true
    }
)
Update-ZoomWebinarRegistrantQuestion -WebinarId 123456789 -Questions $questions

Updates the standard registration questions for the webinar.

.EXAMPLE
$customQuestions = @(
    @{
        title = 'What is your experience level?'
        type = 'single'
        required = $true
        answers = @('Beginner', 'Intermediate', 'Advanced')
    },
    @{
        title = 'Additional comments'
        type = 'short'
        required = $false
    }
)
Update-ZoomWebinarRegistrantQuestion -WebinarId 123456789 -CustomQuestions $customQuestions

Updates the custom registration questions for the webinar.

.EXAMPLE
$questions = @(@{field_name='phone';required=$true})
$customQuestions = @(@{title='Department';type='short';required=$true})
Update-ZoomWebinarRegistrantQuestion -WebinarId 123456789 -Questions $questions -CustomQuestions $customQuestions

Updates both standard and custom registration questions.

#>

function Update-ZoomWebinarRegistrantQuestion {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [int64]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('question')]
        [System.Collections.IDictionary[]]$Questions,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('custom_questions', 'customquestion', 'custom_question')]
        [System.Collections.IDictionary[]]$CustomQuestions
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants/questions"

        # Build request body
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('Questions')) {
            $RequestBody.Add('questions', @($Questions))
        }

        if ($PSBoundParameters.ContainsKey('CustomQuestions')) {
            $RequestBody.Add('custom_questions', @($CustomQuestions))
        }

        # Ensure at least one parameter was provided
        if ($RequestBody.Count -eq 0) {
            Write-Warning 'No questions or custom questions provided. Nothing to update.'
            return
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", 'Update registration questions')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method PATCH

            Write-Output $response
        }
    }
}
