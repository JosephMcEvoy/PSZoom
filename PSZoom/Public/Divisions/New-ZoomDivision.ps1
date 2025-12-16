<#

.SYNOPSIS
Create a new division.

.DESCRIPTION
Creates a new division under the account. Maximum 500 divisions per account.

.PARAMETER DivisionName
The name of the division.

.PARAMETER DivisionDescription
A description of the division.

.EXAMPLE
New-ZoomDivision -DivisionName "Engineering"

.EXAMPLE
New-ZoomDivision -DivisionName "Sales" -DivisionDescription "Sales department division"

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/Createadivision

#>

function New-ZoomDivision {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('division_name', 'name')]
        [string]$DivisionName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('division_description', 'description')]
        [string]$DivisionDescription
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/divisions"

        $body = @{
            division_name = $DivisionName
        }

        if ($PSBoundParameters.ContainsKey('DivisionDescription')) {
            $body.Add('division_description', $DivisionDescription)
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Post

        Write-Output $response
    }
}
