<#

.SYNOPSIS
Iterate through paginated pages to consolidate data or locate records.

.PARAMETER URI
The full URL that needs to be queried.

.PARAMETER ObjectId
ID used to preform a detailed lookup.

.PARAMETER PageSize
Amount of records to be retried for a single query (1 - 100).

.PARAMETER NextPageToken
Next_Page_Token returned from previous query.

.PARAMETER AdditionalQueryStatements
Allows adding additional URl Query statements.

.EXAMPLE
$AllData = Get-ZoomPaginatedData

.EXAMPLE
$SomeData = Get-ZoomPaginatedData -ObjectId $SpecificIDsToQuery

.EXAMPLE
$RawData = Get-ZoomPaginatedData -PageSize 50 -NextPageToken $reponse.next_page_token

.EXAMPLE
$RawData = Get-ZoomPaginatedData -PageSize 50

.OUTPUTS
Array of objects.

#>

function Get-ZoomPaginatedData {
    [CmdletBinding(DefaultParameterSetName="AllData")]
    param (
        [parameter(ParameterSetName="NextRecords")]
        [parameter(ParameterSetName="AllData")]
        [parameter(ParameterSetName="SelectedRecord")]
        [Parameter(Mandatory = $True)]
        [string]$URI,

        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id')]
        [string[]]$ObjectId,

        [parameter(ParameterSetName="NextRecords")]
        [parameter(ParameterSetName="AllData")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [parameter(ParameterSetName="NextRecords")]
        [parameter(ParameterSetName="AllData")]
        [hashtable]$AdditionalQueryStatements

    )
    
    process {

        switch ($PSCmdlet.ParameterSetName) {
        
            "NextRecords" {
        
                $request = [System.UriBuilder]$URI
                $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                $query.Add('page_size', $PageSize)
                if ($AdditionalQueryStatements) {

                    foreach ($Statement in $AdditionalQueryStatements.GetEnumerator() ) {
    
                        $query.Add($Statement.Name, $Statement.Value)
                    }
                }
                if ($NextPageToken) {
                    $query.Add('next_page_token', $NextPageToken)
                }
                $request.Query = $query.ToString()
                
                $AggregatedResponse = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop
            }

            "SelectedRecord" {
                $AggregatedResponse = @()
        
                foreach ($id in $ObjectId) {
                    $request = [System.UriBuilder]$URI
                    $request.path = "{0}/{1}" -f $request.path, $id
                    $AggregatedResponse += Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop
                }

            }
            "AllData" {
                $AggregatedResponse = @()
        
                do {
                    $request = [System.UriBuilder]$URI
                    $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                    $query.Add('page_size', $PageSize)

                    if ($AdditionalQueryStatements) {

                        foreach ($Statement in $AdditionalQueryStatements.GetEnumerator() ) {
    
                            $query.Add($Statement.Name, $Statement.Value)
                        }
                    }

                    if ($response.next_page_token) {
                        $query.Add('next_page_token', $response.next_page_token)
                    }

                    $request.Query = $query.ToString()
                    
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET -ErrorAction Stop
            
                    if ($response.total_records -ne 0) {
                        $TargetProperty =  $response.PSobject.Properties.name | Where-Object {($_ -ne "next_page_token") -and ($_ -ne "page_size") -and ($_ -ne "total_records")}
                        $AggregatedResponse += $response | Select-Object -ExpandProperty $TargetProperty
                    }
            
                } until (-not ($response.next_page_token))
            }
        }

        Write-Output $AggregatedResponse
    }
}
