<#

.SYNOPSIS
Iterate through paginated pages to consolidate data or locate records.

.PARAMETER ObjectIds

.PARAMETER CmdletToRun
Name of function to pass objects into.

.EXAMPLE
Get-ZoomItemFullDetails -ObjectIds $ArrayOfObjects -CmdletToRun 'Get-ZoomPhoneNumber'

.OUTPUTS
Array of objects.

#>

function Get-ZoomItemFullDetails {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id')]
        [string[]]$ObjectIds,
        
        [Parameter(Mandatory = $True)]
        [string]$CmdletToRun
    )

    process {
        if ($PSVersionTable.PSVersion.Major -ge 7) {

            $FullResponse = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()
            $ObjectIds | ForEach-Object -Parallel {
                $Script:PSZoomToken =  $using:PSZoomToken
                $Script:ZoomURI = $using:ZoomURI
                $localFullResponse = $using:FullResponse
                Import-Module PSZoom

                #$using:CmdletToRun $_.Id
                $commandtoexecute = $using:CmdletToRun + " `'" + $_ + "`'"
                $localFullResponse.Add($(Invoke-Expression -Command $commandtoexecute))
            } -ThrottleLimit 10  #Recommended amount for Pro users.  If 429 is returned this number may need to be lowered.  See Rate limit details.
        } else{
            $FullResponse = @()
            $ObjectIds | ForEach-Object {
                # Write-Progress -Activity "Query Zoom API" -Status "$([math]::Round(($FullResponse.count/$ObjectIds.count)*100))% Complete" -PercentComplete ([math]::Round(($FullResponse.count/$ObjectIds.count)*100))
                $FullResponse += Invoke-Expression "$CmdletToRun $_"
            }
        }

        Write-Output $FullResponse
    }
}