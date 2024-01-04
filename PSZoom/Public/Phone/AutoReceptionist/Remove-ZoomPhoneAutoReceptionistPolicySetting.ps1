<#

.SYNOPSIS
Use this API to remove policy sub-setting of a auto receptionist.

.PARAMETER AutoReceptionistId
Use this API to remove policy sub-setting of a auto receptionist.

.PARAMETER DelegateUserID
Unique ID of user to remove.

.PARAMETER PolicyType
Policy number to remove.
Allowed: voice_mail

voice_mail Settings
- voicemail_access_member
    - access_user_id
    - delete
    - download
    - shared_id

.PARAMETER PassThru
Switch to pass AutoReceptionistIds back to user.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomPhoneAutoReceptionistPolicySetting -AutoReceptionistId "n9uyb8ytv7rc6e" -PolicyType "voice_mail"

.EXAMPLE
Remove-ZoomPhoneAutoReceptionistPolicySetting -AutoReceptionistId "n9uyb8ytv7rc6e" -RemoveAllPolicy

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/DeletePolicy

#>

function Remove-ZoomPhoneAutoReceptionistPolicySetting {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    [CmdletBinding(DefaultParameterSetName="SinglePolicy")]
    Param(
        [Parameter(
            ParameterSetName = "SinglePolicy",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'Auto_Receptionist_Id')]
        [string[]]$AutoReceptionistId,

        [Parameter(
            ParameterSetName = "SinglePolicy",
            Mandatory = $True, 
            Position = 1
        )]
        [Alias('UserID')]
        [string]$DelegateUserID,

        [Parameter(
            ParameterSetName = "SinglePolicy",
            Mandatory = $True, 
            Position = 2
        )]
        [Alias('type')]
        [ValidateSet('voice_mail')]
        [string]$PolicyType,




        [switch]$PassThru
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "SinglePolicy" {
                Foreach($AutoReceptionist in $AutoReceptionistId){  

                    $Shared_ID = Get-ZoomPhoneAutoReceptionistPolicy -AutoReceptionistId $AutoReceptionist | Select-Object -ExpandProperty voicemail_access_members | Where-Object access_user_id -eq $DelegateUserID
                    
                    try {
                        $AutoReceptionistName = Get-ZoomPhoneAutoReceptionist -AutoReceptionistId $AutoReceptionist -ErrorAction stop | Select-Object -ExpandProperty Name -ErrorAction stop
                    }
                    catch {
                        $AutoReceptionistName = $AutoReceptionist
                    }

                    try {
                        $DelegateUserName = Get-ZoomPhoneUser -UserId $DelegateUserID -ErrorAction stop | Select-Object -ExpandProperty email -ErrorAction stop 
                    }
                    catch {
                        $DelegateUserName = $DelegateUserID
                    }

                    if (!($Shared_ID)){

                        Write-Error "`'$DelegateUserName`' does not have delegation rights to Auto Recptionist `'$AutoReceptionistName`'."
                        return
                    }

                    $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist/policies/$PolicyType"
                    $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
                    $query.Add('shared_ids', ($Shared_ID | Select-Object -ExpandProperty "shared_id"))
                    $Request.Query = $query.ToString()


$Message = 
@"

Method: DELETE
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

                    if ($pscmdlet.ShouldProcess($Message, $AutoReceptionistname, "Remove delegate user $DelegateUserName")) {
                        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
                
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
    }
}