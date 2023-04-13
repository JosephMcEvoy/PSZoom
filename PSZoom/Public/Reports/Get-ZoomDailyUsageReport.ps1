<#

.SYNOPSIS
Retrieve an active or inactive host report for a specified period of time. 

.DESCRIPTION
Retrieve an active or inactive host report for a specified period of time. 
The time range for the report is limited to a month and the month should fall under the past six months.

.PARAMETER Month
The month.

.PARAMETER Year
The year.


.EXAMPLE
Get-ZoomDailyUsageReport -Year 2019 -Month 2

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomDailyUsageReport {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [int]$Year,

        [Parameter( 
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [int]$Month
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/report/daily"

        if ($Year -or $Query) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        }
        
        if ($Year) {
            $query.Add('year', $Year)
        }

        if ($Month) {
            $query.Add('month', $MOnth)
        }

        if ($query) {
            $Request.Query = $query.ToString()
        }
        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
            
        Write-Output $response
    }
}