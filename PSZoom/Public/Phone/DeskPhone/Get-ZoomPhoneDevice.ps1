<#

.SYNOPSIS
List all the desk phone devices that are configured with Zoom Phone on an account.

.DESCRIPTION
List all the desk phone devices that are configured with Zoom Phone on an account.

.PARAMETER DeviceId
Unique Identifier of the device.

.PARAMETER SiteId
Unique Identifier of the site. This can be found in the ListPhoneSites API.

.PARAMETER DeviceStatus
Whether the device is assigned or not.

.PARAMETER AssigneeType
The type of the assignee. It's available if type = assigned.
Allowed: user ┃ commonArea

.PARAMETER DeviceType
The manufacturer name.
Allowed: algo ┃ audioCodes ┃ cisco ┃ cyberData ┃ grandstream ┃ poly ┃ yealink ┃ other

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, response will include all device details

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listPhoneDevices

.EXAMPLE
Return all devices associated with account
Get-ZoomPhoneDevice

.EXAMPLE
Return the details for a specific device
Get-ZoomPhoneDevice -DeviceId ######

.EXAMPLE
Return devices of a specific manufacture for a specific site.
Get-ZoomPhoneDevice -SiteId ###### -DeviceType "poly" -DeviceStatus "assigned"

#>

function Get-ZoomPhoneDevice {
    
    [CmdletBinding(DefaultParameterSetName="AllData")]
    [Alias("Get-ZoomPhoneUsers")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias(
            'id', 'device_Id'
        )]
        [string]$DeviceId,

        [parameter(
            ParameterSetName="SpecificQuery",
            Mandatory = $true
        )]
        [ValidateSet("assigned","unassigned")]
        [string]$DeviceStatus,

        [Parameter(
            ParameterSetName="SpecificQuery",
            Mandatory = $False, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias(
            'site_id'
        )]
        [string]$SiteId,

        [Parameter(
            ParameterSetName="SpecificQuery"
        )]
        [Alias(
            'assignee_type'
        )]
        [ValidateSet(
            "user","commonArea"
        )]
        [string]$AssigneeType,

        [Parameter(
            ParameterSetName="SpecificQuery"
        )]
        [Alias(
            'device_type'
        )]
        [ValidateSet(
            "algo","audioCodes","cisco","cyberData","grandstream","poly","yealink","other"
        )]
        [string]$DeviceType,

        [parameter(
            ParameterSetName="NextRecords"
        )]
        [ValidateRange(
            1, 100
        )]
        [Alias(
            'page_size'
        )]
        [int]$PageSize = 100,

        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(
            ParameterSetName="NextRecords"
        )]
        [Alias(
            'next_page_token'
        )]
        [string]$NextPageToken,
        
        [parameter(
            ParameterSetName="SpecificQuery"
        )]
        [parameter(
            ParameterSetName="AllData"
        )]
        [switch]$Full = $False
     )

    process {

        $baseURI = "https://api.$ZoomURI/v2/phone/devices"

        switch ($PSCmdlet.ParameterSetName) {

            "NextRecords" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken

            }

            "SelectedRecord" {

                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $DeviceId

            }

            "AllData" {

                $AggregatedResponse = @()
                $types = "assigned","unassigned"

                $types | ForEach-Object {

                    $QueryStatements = @{}

                    $QueryStatements.Add("type", $_)

                    $AggregatedResponse += Get-ZoomPaginatedData -URI $baseURI -PageSize 100 -AdditionalQueryStatements $QueryStatements

                }
            }

            "SpecificQuery" {

                $AggregatedResponse = @()
                $QueryStatements = @{}

                if ($PSBoundParameters.ContainsKey('DeviceStatus')) {
                    $QueryStatements.Add("type", $DeviceStatus)
                }
                if ($PSBoundParameters.ContainsKey('DeviceType')) {
                    $QueryStatements.Add("device_type", $DeviceType)
                }
                if ($PSBoundParameters.ContainsKey('SiteId')) {
                    $QueryStatements.Add("site_id", $SiteId)
                }
                if ($PSBoundParameters.ContainsKey('AssigneeType')) {
                    if ($AssigneeType -eq "user") {
                        $AssigneeType = "user"
                    }elseif ($AssigneeType -eq "commonArea") {
                        $AssigneeType = "commonArea"
                    }
                    $QueryStatements.Add("assignee_type", $AssigneeType)
                }
                $AggregatedResponse += Get-ZoomPaginatedData -URI $baseURI -PageSize 100 -AdditionalQueryStatements $QueryStatements

            }
        }
    
        if ($Full) {
            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty ID
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name
        }

        Write-Output $AggregatedResponse 
    } 
}
