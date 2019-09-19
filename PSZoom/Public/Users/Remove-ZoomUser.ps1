<#

.SYNOPSIS
Delete a user on your account.
.DESCRIPTION
Delete a user on your account.
.PARAMETER Action
Delete action options:
disassociate - Disassociate a user. This is the default.
delete - Permanently dlete a user.
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
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='High')]
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
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret
        
        #Generate Headers with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($id in $userId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId"
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    
            $UserInfoKeyValues = @{
                'action'             = 'Action'
                'transfer_email'     = 'TransferEmail'
                'transfer_meeting'   = 'TransferMeeting'
                'transfer_webinar'   = 'TransferWebinar'
                'transfer_recording' = 'TransferRecording'
            }
            function Remove-NonPSBoundParameters {
                param (
                    $Obj,
                    $Parameters = $PSBoundParameters
                )

                process {
                    $NewObj = @{}
            
                    foreach ($Key in $Obj.Keys) {
                        if ($Parameters.ContainsKey($Obj.$Key)){
                            $Newobj.Add($Key, (get-variable $Obj.$Key).value)
                        }
                    }
            
                    return $NewObj
                }
            }

            $UserInfoKeyValues = Remove-NonPSBoundParameters($UserInfoKeyValues)
            
            #Adds parameters to UserInfo object if not Null
            $UserInfoKeyValues.Keys | ForEach-Object {
                    $Query.Add($_, $UserInfoKeyValues.$_)
            }
            
            $Request.Query = $Query.ToString()
            if ($PScmdlet.ShouldProcess) {
                try {
                    Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method DELETE
                } catch {
                    Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
                } finally {
                    if ($Passthru) {
                        Write-Output $UserId
                    }
                }
            }
        }
    }
}