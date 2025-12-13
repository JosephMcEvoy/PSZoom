<#

.SYNOPSIS
Update a webinar's survey.

.DESCRIPTION
Update a webinar's survey. Use this API to update a webinar survey.

Prerequisites:
* A Pro or a higher plan with a Webinar plan add-on.
* The Webinar Survey feature must be enabled in the host's account.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:update:survey, webinar:update:survey:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER ShowInTheBrowser
Whether to display the survey in the browser. If enabled, the survey will appear in the attendee's browser after leaving the webinar.

.PARAMETER ThirdPartySurvey
The third-party survey link. This is only applicable if ShowInTheBrowser is set to $true.

.PARAMETER CustomSurveyLink
The custom survey link for the third-party survey. Maximum length of 2048 characters.

.PARAMETER CustomSurveyTitle
The title for the custom survey. Maximum length of 128 characters.

.PARAMETER CustomSurveyQuestions
An array of custom survey question hashtables. Each hashtable should contain:
- name: The question text (required)
- type: The question type - 'single', 'multiple', 'rating_scale', 'long_answer' (required)
- show_as_dropdown: Whether to display as dropdown (for single choice)
- answer_required: Whether an answer is required
- answers: Array of answer options (required for single/multiple choice)
- rating_min_value: Minimum rating value (for rating scale)
- rating_max_value: Maximum rating value (for rating scale)
- rating_min_label: Label for minimum rating (for rating scale)
- rating_max_label: Label for maximum rating (for rating scale)
- answer_min_character: Minimum character count (for long answer)
- answer_max_character: Maximum character count (for long answer)

.PARAMETER AnonymousSurvey
Whether to enable anonymous survey responses. If enabled, respondent information will not be attached to survey answers.

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/updateWebinarSurvey

.EXAMPLE
Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true -ThirdPartySurvey 'https://example.com/survey'

Updates the webinar to use a third-party survey link.

.EXAMPLE
$questions = @(
    @{
        name = 'How would you rate this webinar?'
        type = 'rating_scale'
        rating_min_value = 1
        rating_max_value = 5
        rating_min_label = 'Poor'
        rating_max_label = 'Excellent'
        answer_required = $true
    },
    @{
        name = 'What did you enjoy most?'
        type = 'long_answer'
        answer_min_character = 10
        answer_max_character = 500
    }
)
Update-ZoomWebinarSurvey -WebinarId 123456789 -CustomSurveyQuestions $questions -AnonymousSurvey $true

Updates the webinar with custom survey questions and enables anonymous responses.

.EXAMPLE
Update-ZoomWebinarSurvey -WebinarId 123456789 -CustomSurveyTitle 'Feedback Form' -ShowInTheBrowser $true

Updates the custom survey title and enables browser display.

#>

function Update-ZoomWebinarSurvey {
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
        [Alias('show_in_the_browser')]
        [bool]$ShowInTheBrowser,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('third_party_survey')]
        [string]$ThirdPartySurvey,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('custom_survey_link')]
        [ValidateLength(0, 2048)]
        [string]$CustomSurveyLink,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('custom_survey_title')]
        [ValidateLength(0, 128)]
        [string]$CustomSurveyTitle,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('custom_survey_questions')]
        [System.Collections.IDictionary[]]$CustomSurveyQuestions,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('anonymous_survey')]
        [bool]$AnonymousSurvey
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/survey"

        # Build request body
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('ShowInTheBrowser')) {
            $RequestBody.Add('show_in_the_browser', $ShowInTheBrowser)
        }

        if ($PSBoundParameters.ContainsKey('ThirdPartySurvey')) {
            $RequestBody.Add('third_party_survey', $ThirdPartySurvey)
        }

        if ($PSBoundParameters.ContainsKey('AnonymousSurvey')) {
            $RequestBody.Add('anonymous', $AnonymousSurvey)
        }

        # Build custom_survey object if any custom survey parameters are provided
        $customSurvey = @{}

        if ($PSBoundParameters.ContainsKey('CustomSurveyLink')) {
            $customSurvey.Add('link', $CustomSurveyLink)
        }

        if ($PSBoundParameters.ContainsKey('CustomSurveyTitle')) {
            $customSurvey.Add('title', $CustomSurveyTitle)
        }

        if ($PSBoundParameters.ContainsKey('CustomSurveyQuestions')) {
            $customSurvey.Add('questions', @($CustomSurveyQuestions))
        }

        if ($customSurvey.Count -gt 0) {
            $RequestBody.Add('custom_survey', $customSurvey)
        }

        # Ensure at least one parameter was provided
        if ($RequestBody.Count -eq 0) {
            Write-Warning 'No survey parameters provided. Nothing to update.'
            return
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", 'Update survey')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method PATCH

            Write-Output $response
        }
    }
}
