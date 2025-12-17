<#

.SYNOPSIS
Create a new clip upload.

.DESCRIPTION
Create a new clip upload. Use this API to initiate the process of uploading a new Zoom Clip.
This endpoint prepares the system to receive clip file data and returns the necessary information
to complete the upload.

Scopes: clip:write, clip:write:admin

.PARAMETER Name
The name of the clip.

.PARAMETER Description
The description of the clip.

.OUTPUTS
System.Object - Returns an object containing upload details.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/createClipUpload

.EXAMPLE
New-ZoomClipUpload -Name "My Presentation" -Description "Q4 2024 Sales Presentation"

Create a new clip upload with name and description.

.EXAMPLE
New-ZoomClipUpload -Name "Training Video"

Create a new clip upload with just a name.

#>

function New-ZoomClipUpload {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('clip_name')]
        [string]$Name,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('clip_description')]
        [string]$Description
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/files"

        $requestBody = @{
            name = $Name
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $requestBody.Add('description', $Description)
        }

        if ($PSCmdlet.ShouldProcess($Name, "Create Clip Upload")) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10

            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

            Write-Output $response
        }
    }
}
