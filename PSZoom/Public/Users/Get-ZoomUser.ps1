<#

.SYNOPSIS
List specific user(s) on a Zoom account.

.DESCRIPTION
List specific user(s) on a Zoom account.

.PARAMETER UserId
The Unique Identifier or email address.

.PARAMETER LoginType
The user's login method:
0 — FacebookOAuth
1 — GoogleOAuth
24 — AppleOAuth
27 — MicrosoftOAuth
97 — MobileDevice
98 — RingCentralOAuth
99 — APIuser
100 — ZoomWorkemail
101 — SSO

The following login methods are only available in China:
11 — PhoneNumber
21 — WeChat
23 — Alipay

You can use the number or corresponding text (e.g. 'FacebookOauth' or '0')

.PARAMETER EncryptedEmail
Whether the email address passed for the $UserId value is an encrypted email address. 
Add the -EncryptedEmail switch to specify this is $True.

.PARAMETER SearchByUniqueId
Whether the queried userId value is an employee unique ID. 
    true - The queried ID is an employee's unique ID.  Add the -SearchByUniqueId 
    false - The queried ID is not an employee's unique ID. 

.PARAMETER Status
User statuses:
Active - Users with an active status. This is the default status.
Inactive - Users with an inactive status.
Pending - Users with a pending status.
All - Returns all users

.PARAMETER RoleId
The role's unique ID. Use this parameter to filter the response by a specific role. You can use the List roles API to get a role's unique ID value.

.PARAMETER License
The user's license. Filter the response by a specific license.
Allowed: zoom_workforce_management ┃ zoom_compliance_management

.PARAMETER FullApiResponse
The switch FullApiResponse will return the default Zoom API response.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/users
https://developers.zoom.us/docs/api/rest/reference/user/methods/#operation/user

.EXAMPLE
Return a list of all the zoom  users.
Get-ZoomUsers


.EXAMPLE
Return an entry for a specific user
Get-ZoomUser -UserId "284bqlwmrtg9uwsrg"


.EXAMPLE
Return a user that matches userid and logintype
Get-ZoomUser -UserId "284bqlwmrtg9uwsrg" -LoginType "Zoom Work email"


.EXAMPLE
Get a page of zoom users with  accounts.
Get-ZoomUsers -PageSize 100 -NextPageToken "8w7vt487wqtb457qwt4"

#>

function Get-ZoomUser {
    [CmdletBinding(DefaultParameterSetName="SpecificQuery")]
    [Alias("Get-ZoomUsers")]
    param (
        [Parameter(
            ParameterSetName="SelectedRecord",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName="SelectedRecordQuery",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'User_Id')]
        [string[]]$UserId,

        
        [Parameter(
            ParameterSetName="SelectedRecordQuery",
            Mandatory = $True
        )]
        [Alias('login_type')]
        [ValidateSet(0,1,24,27,97,98,99,100,101,11,21,23)]
        [string]$LoginType,

        
        [Parameter(ParameterSetName="SelectedRecordQuery")]
        [Alias('encrypted_email')]
        [switch]$EncryptedEmail,


        [Parameter(ParameterSetName="SelectedRecordQuery")]
        [Alias('search_by_unique_id')]
        [switch]$SearchByUniqueId,




        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'SpecificQuery'
        )]
        [ValidateSet('active', 'inactive', 'pending', 'all')]
        [string]$Status = 'all',


        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'SpecificQuery'
        )]
        [Alias('role_id')]
        [int]$RoleId,


        [Parameter(
            ParameterSetName = 'SpecificQuery'
        )]
        [ValidateSet('zoom_workforce_management', 'zoom_compliance_management')]
        [string]$License,




        [parameter(ParameterSetName="NextRecords")]
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 100,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [parameter(ParameterSetName="NextRecords")]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        #[parameter(ParameterSetName="SelectedRecordQuery")]
        [parameter(ParameterSetName="AllData")]
        [switch]$Full = $False
     )

    process {
        $baseURI = "https://api.$ZoomURI/v2/users/"

        switch ($PSCmdlet.ParameterSetName) {
            "NextRecords" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize $PageSize -NextPageToken $NextPageToken
            }

            "SelectedRecord" {
                foreach ($id in $UserId) {
                    
                    $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -ObjectId $id
                }
            }

            "AllData" {
                $AggregatedResponse = Get-ZoomPaginatedData -URI $baseURI -PageSize 100
            }

            "SpecificQuery" {
                $AggregatedResponse = @()
                $QueryStatements = @{}

                if (($PSBoundParameters.ContainsKey('Status')) -and ($Status -ne "all")) {
                    $QueryStatements.Add('status', $Status)
                }

                if ($PSBoundParameters.ContainsKey('RoleId')) {
                    $QueryStatements.Add('role_id', $RoleId)
                }

                if ($PSBoundParameters.ContainsKey('License')) {
                    $QueryStatements.Add('license', $License)
                }

                

                if ($Status -eq "all") {

                    $StatusOptions = 'inactive', 'pending', 'active'
                    foreach ($Option in $StatusOptions) {

                        $QueryStatements.Remove('status')
                        $QueryStatements.Add('status', $Option)

                        $AggregatedResponse += Get-ZoomPaginatedData -URI $baseURI -PageSize 100 -AdditionalQueryStatements $QueryStatements
                    }
                }else {

                    $AggregatedResponse += Get-ZoomPaginatedData -URI $baseURI -PageSize 100 -AdditionalQueryStatements $QueryStatements
                }
                
            }
            "SelectedRecordQuery" {

                $QueryStatements = @{}
                $AggregatedResponse = @()

                if ($PSBoundParameters.ContainsKey('EncryptedEmail')) {
                    $QueryStatements.Add('encrypted_email', $True)
                }
    
                if ($PSBoundParameters.ContainsKey('LoginType')) {
                    $LoginType = ConvertTo-LoginTypeCode -Code $LoginType
                    $QueryStatements.Add('login_type', $LoginType)
                }

                if ($PSBoundParameters.ContainsKey('SearchByUniqueId')) {
                    $QueryStatements.Add('search_by_unique_id', $True)
                }

                foreach ($id in $UserId) {

                    $baseURIplusUserID = "{0}{1}/" -f $baseURI,$id
                    $AggregatedResponse += Get-ZoomPaginatedData -URI $baseURIplusUserID -PageSize 100 -AdditionalQueryStatements $QueryStatements
                }
            }
        }


        if ($Full) {
            $AggregatedIDs = $AggregatedResponse | select-object -ExpandProperty id
            $AggregatedResponse = Get-ZoomItemFullDetails -ObjectIds $AggregatedIDs -CmdletToRun $MyInvocation.MyCommand.Name
        }

        Write-Output $AggregatedResponse 
    } 
}
