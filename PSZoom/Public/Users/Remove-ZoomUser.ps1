<#

.SYNOPSIS
Delete a user on your account.

.DESCRIPTION
Use this API to disassociate (unlink) a user or permanently delete a user. 

.PARAMETER Action
Delete action options:
disassociate - Disassociate a user. This is the default.
delete - Permanently delete a user.
Note: To delete pending user in the account, use disassociate.

.PARAMETER EncryptedEmail
Whether the email address passed for the userId value is an encrypted email address.

.PARAMETER TransferEmail
Transfer email.

.PARAMETER TransferMeeting
Transfer meeting.

.PARAMETER TransferWebinar
Transfer webinar.

.PARAMETER TransferRecording
Transfer recording.

.PARAMETER Transferwhiteboard
When you delete the user, whether to transfer all their Zoom Whiteboard data to another user.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomUser 'sjackson@lawfirm.com' -action 'delete' -TransferEmail 'jsmith@lawfirm.com' -TransferMeeting

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userdelete

#>

function Remove-ZoomUser {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Medium')]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'id')]
        [string[]]$UserId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('disassociate', 'delete')]
        [string]$Action = 'disassociate',

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('encrypted_email')]
        [switch]$EncryptedEmail,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_email')]
        [string]$TransferEmail,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_meeting')]
        [switch]$TransferMeeting,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_webinar')]
        [switch]$TransferWebinar,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_recording')]
        [switch]$TransferRecording,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('transfer_whiteboard')]
        [switch]$TransferWhiteboard,

        [switch]$Passthru
    )

    process {
        foreach ($user in $UserId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$user"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $ZoomUserToBeDeletedInfo = get-zoomuser -UserId $user -ErrorAction Stop
            
            if ($ZoomUserToBeDeletedInfo.status -ne "pending") {
            
                $query.Add('action', $Action)

                if ($PSBoundParameters.ContainsKey('EncryptedEmail')) {
                    $query.Add('encrypted_email', $EncryptedEmail)
                }

                if ($PSBoundParameters.ContainsKey('TransferEmail')) {
                    $query.Add('transfer_email', $TransferEmail)
                }

                if ($PSBoundParameters.ContainsKey('TransferMeeting')) {
                    $query.Add('transfer_meeting', $TransferMeeting)
                }

                if ($PSBoundParameters.ContainsKey('TransferWebinar')) {
                    $query.Add('transfer_webinar', $TransferWebinar)
                }

                if ($PSBoundParameters.ContainsKey('TransferRecording')) {
                    $query.Add('transfer_recording', $TransferRecording)
                }

                if ($PSBoundParameters.ContainsKey('TransferWhiteboard')) {
                    $query.Add('transfer_whiteboard', $Transferwhiteboard)
                }
                
                $request.Query = $query.ToString().ToLower()
            }

            
            if ($PScmdlet.ShouldProcess($user, 'Remove')) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method DELETE

                if ($Passthru) {
                    Write-Output $UserId
                } else {
                    Write-Output $response
                }
                
            }
        }
    }
}
