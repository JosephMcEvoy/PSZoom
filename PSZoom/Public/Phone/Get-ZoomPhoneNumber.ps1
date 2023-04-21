<#

.SYNOPSIS
List all Zoom Phone numbers that are associated with account Account.

.DESCRIPTION
List all Zoom Phone numbers that are associated with account Account.

.PARAMETER PhoneNumberId
ID number[s] of common area phones to be queried.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
The full details of each Common Area Phone.

.PARAMETER Assigned
List all numbers that are assigned to Zoom Phone users.

.PARAMETER Unassigned
List all numbers that are unassigned.

.OUTPUTS
An array of Objects

.EXAMPLE
$AllData = Get-ZoomPhoneNumber

.EXAMPLE
$SomeData = Get-ZoomPhoneNumber -ObjectId $SpecificIDsToQuery

.EXAMPLE
$AllData = Get-ZoomPhoneNumber -Full

.EXAMPLE
$RawData = Get-ZoomPhoneNumber -Assigned

.EXAMPLE
$AllData = Get-ZoomPhoneNumber -Unassigned

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listAccountPhoneNumbers
	

#>

function Get-ZoomPhoneNumber {

    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneNumbers")]
    param ( [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'phone_numbers_Id')]
        [string[]]$PhoneNumberId,

        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [parameter(ParameterSetName="AllData")]
        [switch]$Full = $False,

        [parameter(ParameterSetName="AllData")]
        [ValidateSet("All","Assigned","Unassigned","BYOC")]
        [string]$Filter = "All"

    )

    process {

        $BASEURI = "https://api.$ZoomURI/v2/phone/numbers"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize $PageSize -NextPageToken $NextPageToken

            }
            "SelectedRecord" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -ObjectId $PhoneNumberId

            }
            "AllData" {

                switch ($Filter) {

                    "Assigned" {
        
                        $QueryStatements = @{"type" = "assigned"}
        
                    }
                    "Unassigned" {

                        $QueryStatements = @{"type" = "unassigned"}
        
                    }
                    "All" {
        
                        $QueryStatements = @{"type" = "all"}
        
                    }
                    "BYOC" {
        
                        $QueryStatements = @{"type" = "byoc"}
        
                    }
                }

                $AggregatedResponse = Get-ZoomPaginatedData -URI $BASEURI -PageSize 100 -AdditionalQueryStatements $QueryStatements
            
            }
        }

        if ($Full) {

            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty ID
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name

        }

        Write-Output $AggregatedResponse

    }	
}