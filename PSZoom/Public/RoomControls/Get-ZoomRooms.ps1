<#

.SYNOPSIS
Retrieve the Zoom Rooms ID and name.
.DESCRIPTION
Retrieve the Zoom Rooms ID and name.
.PARAMETER JsonRPC
A String specifying the version of the JSON-RPC protocol. Default is 2.0.
.PARAMETER Name
Retrive all zoom rooms, if it is blank, retrive zoom rooms. Max of 100.
.PARAMETER Page
Smiliar to pagination, retrive zoom rooms belongs to this page if there are too many zoom rooms under an account. 
The value should be greater than or equal to 1 and less than or equal to 10.
.PARAMETER PageSize
Smiliar to pagination, retrive how many zoom rooms per page. the value should be greater than or equal to 1 and less than or equal to 100.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
When using -Full switch, receives JSON Response that looks like:
    {
    "jsonrpc": "2.0",
    "result": {
        "send_at": "2017-09-26T05:50:29Z",
        "data": [
        {
            "zr_name": "My Zoom Room1",
            "zr_id": "63UtYMhSQZaBRPCNRXrD8A"
        },
        {
            "zr_name": "My Zoom Room2",
            "zr_id": "295bUg9STYaK-7NKz6KB1g"
        }
        ]
    },
    "id": "49cf01a4-517e-4a49-b4d6-07237c38b749"
    }

When not using -Full, a JSON response that looks like:
    {
        "zr_name": "My Zoom Room1",
        "zr_id": "63UtYMhSQZaBRPCNRXrD8A"
    },
    {
        "zr_name": "My Zoom Room2",
        "zr_id": "295bUg9STYaK-7NKz6KB1g"
    }
.LINK
https://marketplace.zoom.us/docs/guides/zoom-rooms/zoom-rooms-api
.EXAMPLE
Get-ZoomRooms


#>

function Get-ZoomRooms {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName = $True,
            ValueFromPipeline = $True
        )]
        [Alias('zr_name')]
        [string]$Name = '',

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateRange(1,10)]
        [int]$Page = 1,
            
        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 2
        )]
        [ValidateRange(1,100)]
        [Alias('page_size')]
        [int]$PageSize = 100,

        [Parameter(
            Position = 3,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Method = 'list',

        [Parameter(
            Position = 4,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$JsonRpc = '2.0',

        [switch]$Full = $False,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/zrlist"

        $RequestBody = @{
            'jsonrpc'   = $JsonRpc
            'method'    = $Method
            'params'    = @{
                'zr_name'   = $Name
                'page'      = $Page
                'page_size' = $PageSize
            }
        }
        
        $RequestBody = ConvertTo-Json $RequestBody -Depth 2

        try {
           $response = Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body $RequestBody -Method POST
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }

        if ($Full) {
            Write-Output $response
        } else {
            Write-Output $response.result.data
        }
    }
}
