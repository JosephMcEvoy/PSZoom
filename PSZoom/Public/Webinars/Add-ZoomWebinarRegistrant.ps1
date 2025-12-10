<#

.SYNOPSIS
Register a participant for a webinar.

.DESCRIPTION
Register a participant for a webinar. A host or co-host can require registration for a webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER OccurrenceIds
Occurrence IDs for recurring webinars.

.PARAMETER Email
A valid email address of the registrant.

.PARAMETER FirstName
Registrant's first name.

.PARAMETER LastName
Registrant's last name.

.PARAMETER Address
Registrant's address.

.PARAMETER City
Registrant's city.

.PARAMETER Country
Registrant's country.

.PARAMETER Zip
Registrant's zip/postal code.

.PARAMETER State
Registrant's state/province.

.PARAMETER Phone
Registrant's phone number.

.PARAMETER Industry
Registrant's industry.

.PARAMETER Org
Registrant's organization.

.PARAMETER JobTitle
Registrant's job title.

.PARAMETER Comments
Registrant's comments.

.PARAMETER CustomQuestions
Custom questions.

.EXAMPLE
Add-ZoomWebinarRegistrant -WebinarId 123456789 -Email 'john@company.com' -FirstName 'John' -LastName 'Doe'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarRegistrantCreate

#>

function Add-ZoomWebinarRegistrant {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('occurrence_ids')]
        [string]$OccurrenceIds,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Email,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('first_name')]
        [string]$FirstName,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('last_name')]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Address,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$City,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Country,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Zip,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$State,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Phone,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Industry,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Org,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('job_title')]
        [string]$JobTitle,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Comments,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('custom_questions')]
        [hashtable[]]$CustomQuestions
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants"

        if ($PSBoundParameters.ContainsKey('OccurrenceIds')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('occurrence_ids', $OccurrenceIds)
            $Request.Query = $query.ToString()
        }

        $requestBody = @{
            'email'      = $Email
            'first_name' = $FirstName
            'last_name'  = $LastName
        }

        $optionalParams = @{
            'address'          = 'Address'
            'city'             = 'City'
            'country'          = 'Country'
            'zip'              = 'Zip'
            'state'            = 'State'
            'phone'            = 'Phone'
            'industry'         = 'Industry'
            'org'              = 'Org'
            'job_title'        = 'JobTitle'
            'comments'         = 'Comments'
            'custom_questions' = 'CustomQuestions'
        }

        foreach ($key in $optionalParams.Keys) {
            $paramName = $optionalParams[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
