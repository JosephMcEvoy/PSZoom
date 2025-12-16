<#

.SYNOPSIS
Update a division.

.DESCRIPTION
Updates an existing division's name or description.

.PARAMETER DivisionId
The division ID.

.PARAMETER DivisionName
The new name for the division.

.PARAMETER DivisionDescription
The new description for the division.

.EXAMPLE
Update-ZoomDivision -DivisionId "abc123" -DivisionName "New Name"

.EXAMPLE
Update-ZoomDivision -DivisionId "abc123" -DivisionDescription "Updated description"

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/Updateadivision

#>

function Update-ZoomDivision {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('division_id', 'id')]
        [string]$DivisionId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('division_name', 'name')]
        [string]$DivisionName,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('division_description', 'description')]
        [string]$DivisionDescription
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/divisions/$DivisionId"

        $body = @{}

        if ($PSBoundParameters.ContainsKey('DivisionName')) {
            $body.Add('division_name', $DivisionName)
        }

        if ($PSBoundParameters.ContainsKey('DivisionDescription')) {
            $body.Add('division_description', $DivisionDescription)
        }

        if ($body.Count -gt 0) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Patch

            if ($null -eq $response) {
                Write-Output $true
            } else {
                Write-Output $response
            }
        }
    }
}
