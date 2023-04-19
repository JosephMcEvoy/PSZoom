<#

.SYNOPSIS
View specific site information in the Zoom Phone account.

.DESCRIPTION
View specific site information in the Zoom Phone account.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a site's settings templates.
Get-ZoomPhoneSite -SiteId ##########

.EXAMPLE
Retrieve inforation for all sites.
Get-ZoomPhoneSite

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listPhoneSites

#>

function Get-ZoomPhoneCommonArea {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string[]]$CommonAreaId,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [parameter(ParameterSetName="SelectedRecord")]
        [parameter(ParameterSetName="AllData")]
        [switch]$Full = $False

     )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/common_areas"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $request = [System.UriBuilder]$BASEURI
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                $query.Add('page_size', $PageSize)
                if ($NextPageToken) {
                    $query.Add('next_page_token', $NextPageToken)
                }
                $request.Query = $query.ToString()
                
                $AggregatedResponse = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop


            }
            "SelectedRecord" {

                $AggregatedResponse = @()

                foreach ($id in $CommonAreaId) {
                    $request = [System.UriBuilder]$BASEURI
                    $request.path = "{0}/{1}" -f $request.path, $id
                    $AggregatedResponse += Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop

                }

            }
            "AllData" {

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
                        $AggregatedResponse += $response | Select-Object -ExpandProperty common_areas #| Select-Object @{Name="commonAreaId";Expression={$_.id}},site,display_name,extension_number,calling_plans,phone_numbers,desk_phones
                    }

                } until (!($response.next_page_token))

            }

        }

        if ($Full -and ($PSVersionTable.PSVersion.Major -gt 10)) {

            $TempAggregatedResponse = $AggregatedResponse
            $AggregatedResponse = @()
            $TempAggregatedResponse | ForEach-Object -Parallel {

                $AggregatedResponse += Get-ZoomPhoneCommonArea -CommonAreaId $_.id

            } -ThrottleLimit 15



            <#
            
            $JobSb = {
            param($obid)

            # make api call

            write-output = [PsCustomObject]@{
                Obid = $obid
                ApiResult = 0;
            }
            }

            # start jobs for all objects
            Foreach ($object in $Collection) {
                Start-Job -ScriptBlock $JobSB -ArgumentList $object.Id -Name $object.name
            }

            # wait for jobs to finish
            while (get-job) {
                Get-Job | Where-Object State -NE 'Running' | ForEach-Object {
                    if ($_.State -ne 'Completed') {
                        Write-Warning ('Job [{0}] [{1}] ended with state [{2}].' -f $_.id,$_.Name,$_.State)
                    } else {
                        $JobResults = @(Receive-Job $_)
                    }

                    # write results to datatable

                    remove-job $_
                }
                start-sleep -Seconds 1
            }


            #>

        } elseif ($Full -and ($PSVersionTable.PSVersion.Major -lt 7)) {

            $TempAggregatedResponse = $AggregatedResponse
            Clear-Variable AggregatedResponse
            $AggregatedResponse = $TempAggregatedResponse | Get-ZoomPhoneCommonArea 

        }
        
        Write-Output $AggregatedResponse 
        

    }

}