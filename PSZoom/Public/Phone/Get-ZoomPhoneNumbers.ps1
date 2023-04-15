<#

.SYNOPSIS
List all Zoom Phone numbers that are associated with account Account.

.DESCRIPTION
List all Zoom Phone numbers that are associated with account Account.


.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listAccountPhoneNumbers
	
.EXAMPLE
Get-ZoomPhoneNumbers
#>

function Get-ZoomPhoneNumbers {

    [CmdletBinding()]
    param ()

    process {
        $page_size = '100'
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/numbers?page_size=$page_size"        
        $QueryAmount = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop | Select-Object -ExpandProperty total_records
        $TotalQueries = [math]::ceiling($QueryAmount/100)

        do {

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop
            $next_page_token = $response | Select-Object -ExpandProperty next_page_token
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/numbers?page_size=$page_size&next_page_token=$next_page_token"
            $TotalQueries += -1
            $AllNumbers += $response | Select-Object -ExpandProperty phone_numbers

        } until ($TotalQueries -eq 0)

        
        
        Write-Output $AllNumbers        
    }	
}