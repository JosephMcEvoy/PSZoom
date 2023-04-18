<#

.SYNOPSIS
List all Zoom Phone numbers that are associated with account Account.

.DESCRIPTION
List all Zoom Phone numbers that are associated with account Account.

.PARAMETER Assigned
List all numbers that are assigned to Zoom Phone users.

.PARAMETER Unassigned
List all numbers that are unassigned.

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listAccountPhoneNumbers
	
.EXAMPLE
Get-ZoomPhoneNumbers
#>

function Get-ZoomPhoneNumbers {

    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [parameter(ParameterSetName="Assigned")]
        [switch]$Assigned = $False,

        [parameter(ParameterSetName="Unassigned")]
        [switch]$Unassigned = $False

    )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/numbers"
        $PageSize = 30
        $AggregatedResponse = @()

        do {

            $request = [System.UriBuilder]$BASEURI
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('page_size', $PageSize)
            if ($response.next_page_token) {
                $query.Add('next_page_token', $response.next_page_token)
            }
            $request.Query = $query.ToString()
            
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop
            
            if ($response.total_records -ne 0) {
                $AggregatedResponse += $response | Select-Object -ExpandProperty phone_numbers
            }

        } until (!($response.next_page_token))

        


        switch ($PSCmdlet.ParameterSetName) {

            "Assigned" {

                Write-Output $AggregatedResponse | Where-Object {$_.PSobject.Properties.name -match "assignee"}

            }
            "Unassigned" {
                # -notmatch did not return expected results
                Write-Output $AggregatedResponse | Where-Object {!($_.PSobject.Properties.name -match "assignee")}

            }
            "AllData" {

                Write-Output $AggregatedResponse

            }
        }
    }	
}