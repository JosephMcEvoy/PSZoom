<#

.SYNOPSIS
Delete a user on your account.

.DESCRIPTION
Delete a user on your account.

.PARAMETER Action
Delete action options:
disassociate - Disassociate a user. This is the default.
delete - Permanently delete a user.
Note: To delete pending user in the account, use disassociate.

.PARAMETER TransferEmail
Transfer email.

.PARAMETER TransferMeeting
Transfer meeting.

.PARAMETER TransferWebinar
Transfer webinar.

.PARAMETER TransferRecording
Transfer recording.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

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

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret,

        [switch]$Passthru
    )

    begin {
        #Generate Headers with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($user in $UserId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/users/$user"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            $query.Add('action', $Action)

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
            
            $request.Query = $query.ToString().ToLower()
            
            if ($PScmdlet.ShouldProcess($user, 'Remove')) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method DELETE -ApiKey $ApiKey -ApiSecret $ApiSecret

                if ($Passthru) {
                    Write-Output $UserId
                } else {
                    Write-Output $response
                }
                
            }
        }
    }
}
