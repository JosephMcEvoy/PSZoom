<#

.SYNOPSIS
Retrieve an active or inactive host report for a specified period of time. 

.DESCRIPTION
Retrieve an active or inactive host report for a specified period of time. 
The time range for the report is limited to a month and the month should fall under the past six months.

.PARAMETER Type
Active or Inactive. Defaults to Inactive.

.PARAMETER From
Start date in 'yyyy-mm-dd' format.

.PARAMETER To
End date.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 30.

.PARAMETER PageNumber
The current page number of returned records. Default is 1.

.PARAMETER All
Use this switch to retrieve the last 6 months of reports. Zoom limits the reports to the last 6 months.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.EXAMPLE
Get-ZoomActiveInactiveHostReports -from '2019-07-01' -to '2019-07-31' -page 1 -pagesize 300
Get-ZoomActiveInactiveHostReports -type inactive -all

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomActiveInactiveHostReports {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default'
        )]
        [ValidatePattern('([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')]
        [string]$From,

        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidatePattern('([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')]
        [string]$To,

        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1, 300)]
        [Alias('size', 'page_size')]
        [int]$PageSize = 30,

        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page', 'page_number')]
        [int]$PageNumber = 1,

        [ValidateSet('active', 'inactive')]
        [string]$Type = 'inactive', #Zoom defaults to inactive if this isn't sent in the query.

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        if ($All) {
            [int]$requests = 0
            $monthRanges = (Get-LastSixMonthsDateRanges)
            $allReports = New-Object System.Collections.Generic.List[System.Object]

            foreach ($key in $monthRanges.keys) {
                $TotalPages = (Get-ZoomActiveInactiveHostReports -from "$($monthRanges.$key.begin)" -to "$($monthRanges.$key.end)" -pagesize 300 -pagenumber 1 -type $Type).page_count
                
                for ($i = 1; $i -le $TotalPages; $i++) {
                    if (($requests % 10) -eq 0) { #Zoom limits the number of requests to 10 per second
                        Start-Sleep -seconds 2
                    }
        
                    $currentPage = (Get-ZoomActiveInactiveHostReports -from "$($monthRanges.$key.begin)" -to "$($monthRanges.$key.end)" -pagesize 300 -pagenumber $i -type $Type).users
                    
                    foreach ($entry in $currentPage) {
                        $allReports.Add($entry)
                    }
        
                    $requests++
                }
            }
            write-output $allReports
        } else {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/report/users"
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $Query.Add('from', $From)
            $Query.Add('to', $To)
            $Query.Add('page_size', $PageSize)
            $Query.Add('page_number', $PageNumber)
            $Query.Add('type', $Type)
            $Request.Query = $Query.ToString()
            
            try {
                $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method GET
            } catch {
                Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
            }
            
            Write-Output $Response
        }
    }
}