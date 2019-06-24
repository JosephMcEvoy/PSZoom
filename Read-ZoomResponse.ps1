<#

.SYNOPSIS
Parses Zoom REST response so errors are returned properly
.PARAMETER Response
The JSON response from the Api call.
.PARAMETER RequestBody
The hashtable that was sent through the Api call.
.PARAMETER Endpoint
Api endpoint Url that was called.
.PARAMETER RetryOnRequestLimitReached
If the Api request limit is reached, retry once after 1 second.
.EXAMPLE
Invoke-RestMethod -Uri $Endpoint -Body $RequestBody -Method Post |
Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Endpoint -Endpoint $Endpoint

#>

function Read-ZoomResponse {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
			ValueFromPipeline = $true
		)]
        [PSCustomObject]$Response,

        [Parameter(Mandatory = $true)]
        [hashtable]$RequestBody,

        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter(Mandatory = $false)]
        [bool]$RetryOnRequestLimitReached = $true
    )

    $ApiCallInfo = "Api Endpoint: $Endpoint`n"
    $ApiCallInfo += "Api call body:$($RequestBody | Out-String)"

    if ($Response.PSObject.Properties.Name -match 'error') {
        Write-Error -Message "$($Response.error.message)`n$ApiCallInfo" -ErrorId $Response.error.code -Category InvalidOperation

        if ($RetryOnRequestLimitReached -and $Response.error.code -eq 403) {
            Write-Warning "Retrying in one second..."
            Start-Sleep -Seconds 1

            Invoke-RestMethod -Uri $Endpoint -Body $RequestBody -Method Post |
                Read-ZoomResponse -RequestBody $RequestBody -Endpoint $Endpoint
        }
    } else {
        Write-Verbose "$($Response.error.message)`nApi call body:$($RequestBody | Out-String)"
        Write-Output $Response
    }
}