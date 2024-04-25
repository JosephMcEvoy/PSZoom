<#

.SYNOPSIS
Add policy setting to Auto Receptionist.

.DESCRIPTION
Add policy setting to Auto Receptionist.  Currently, only voice_mail is supported by API.
                    
.PARAMETER AutoReceptionistId
The Unique ID of the Auto Receptionist to manage.

.PARAMETER DelegateVMAccessUserID
Unique ID of user who is granted access to manage Auto Receptionist's voicemail.

.PARAMETER DelegateUserPermitVMDelete
Allows User to Delete Auto Receptionist's voicemails.

.PARAMETER DelegateUserPermitVMDownload
Allows User to Download Auto Receptionist's voicemails.

.OUTPUTS
No output. Can use Passthru switch to pass AutoReceptionistId to output.

.EXAMPLE
Add-ZoomPhoneAutoReceptionistPolicySetting -AutoReceptionistId "5e7tv9y80bu9n-i0nbvc7e5x6" -DelegateVMAccessUserID "bwo8arsny6b328" -DelegateUserPermitVMDelete $false -DelegateUserPermitVMDownload $true

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/AddPolicy


#>

function Add-ZoomPhoneAutoReceptionistPolicySetting {    
    [alias("Add-ZoomPhoneAutoReceptionistPolicySettings")]
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('Id', 'ids', 'user_id', 'AutoReceptionistIds')]
        [string[]]$AutoReceptionistId,

        [Parameter(Mandatory = $True)]
        [string]$DelegateVMAccessUserID,

        [Parameter()]
        [bool]$DelegateUserPermitVMDelete,

        [Parameter()]
        [bool]$DelegateUserPermitVMDownload,        

        [switch]$PassThru
    )
    
    begin {
        
        # Made so additional types can easily be added in the future
        $PolicyTypes = @()

        #region voice_mail Settings

            # Organizing voice_mail settings
            $voicemail_access_member = @{ }
            if ($PSBoundParameters.ContainsKey('DelegateVMAccessUserID')) {
                $voicemail_access_member.Add("access_user_id", $DelegateVMAccessUserID)
            }
            if ($PSBoundParameters.ContainsKey('DelegateUserPermitVMDelete')) {
                $voicemail_access_member.Add("delete", $DelegateUserPermitVMDelete)
            }
            if ($PSBoundParameters.ContainsKey('DelegateUserPermitVMDownload')) {
                $voicemail_access_member.Add("download", $DelegateUserPermitVMDownload)
            }

            # Add settings to object
            $voice_mail = [PSCustomObject]@{
                voicemail_access_member = $voicemail_access_member
            }

            # If there are voice_mail settings, add to the policy type to add
            if ($voice_mail){
                $PolicyTypes += [PSCustomObject]@{
                    voice_mail = $voice_mail
                }
            }

        #endregion voice_mail Settings

    }
    process {

        foreach ($AutoReceptionist in $AutoReceptionistId) {

            foreach($PolicyType in $PolicyTypes) {

                $PolicyTypeName = $PolicyType | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name'
                $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists/$AutoReceptionist/policies/$PolicyTypeName"

                #region body
                    $RequestBody = $PolicyType | Select-Object -ExpandProperty $PolicyTypeName | ConvertTo-Json -Depth 10
                #endregion body

                #region whatif Message
$Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@
                #endregion whatif Message

                #region send API calls
                if ($pscmdlet.ShouldProcess($Message, $AutoReceptionistId, "Update policy")) {
                    $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
            
                    if (-not $PassThru) {
                        Write-Output $response
                    }
                }
                #endregion send API calls
            }
        }

        if ($PassThru) {
            Write-Output $AutoReceptionistId
        }
    }
}
