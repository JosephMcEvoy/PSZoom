<#

.SYNOPSIS
Update a specific user Zoom Phone Auto Receptionist account.
                    
.PARAMETER AutoReceptionistId
Unique number used to locate Auto Receptionist Phone account.

.PARAMETER CostCenter
The cost center the Auto Receptionist belongs to.

.PARAMETER Department
The department the Auto Receptionist belongs to.

.PARAMETER Name
Display name of the Auto Receptionist.

.PARAMETER AudioPromptLanguage
The Audio Prompt Language the Auto Receptionist belongs to. 

.PARAMETER ExtensionNumber
Extension number of the phone. If the site code is enabled, provide the short extension number instead.

.PARAMETER Timezone
Timezone ID for the Auto Receptionist.

.OUTPUTS
No output. Can use Passthru switch to pass AutoReceptionistId to output.

.EXAMPLE
Assign new extension number
Update-ZoomPhoneAutoReceptionist -AutoReceptionistId "be5w6n09wb3q567" -ExtensionNumber 011234567

.EXAMPLE
Change Auto Receptionist phone display name
Update-ZoomPhoneAutoReceptionist -AutoReceptionistId "be5w6n09wb3q567" -Name "Finance Main Line"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateAutoReceptionist

#>

function Update-ZoomPhoneAutoReceptionist {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('id')]
        [string]$AutoReceptionistId,

        [Parameter()]
        [string]$CostCenter,

        [Parameter()]
        [string]$Department,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [int64]$ExtensionNumber,

        [Parameter()]
        [string]$AudioPromptLanguage,

        [Parameter()]
        [string]$Timezone,

        [switch]$PassThru
    )

    process {
        foreach ($AutoReceptionist in $AutoReceptionistId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist"

            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'cost_center'            = $CostCenter
                    'audio_prompt_language'  = $AudioPromptLanguage
                    'department'             = $Department
                    'name'                   = $Name
                    'extension_number'       = $ExtensionNumber
                    'timezone'               = $Timezone
                }
    
                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not (([string]::IsNullOrEmpty($KeyValuePairs.$_)) -or ($KeyValuePairs.$_ -eq 0) )) {
                        $RequestBody.Add($_, $KeyValuePairs.$_)
                    }
                }
            #endregion body

            if ($RequestBody.Count -eq 0) {
                Write-Error "Request must contain at least one Auto Receptionist account change."
                return
            }

            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
            $Message = 
@"

Method: PATCH
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $AutoReceptionistId, "Update")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $AutoReceptionistId
        }
    }
}
