<#

.SYNOPSIS
Delete a message sent by a Zoom Marketplace Chatbot app.

.DESCRIPTION
Deletes a message sent by your Marketplace Chatbot app.
Requires a Zoom Marketplace Chatbot app with the imchat:bot OAuth scope.

.PARAMETER MessageId
The message ID of the message to delete.

.PARAMETER RobotJid
The Bot JID. You can find this value in the Feature section of your Marketplace Chatbot app.

.PARAMETER AccountId
The authorized account's account ID.

.PARAMETER UserJid
The JID of the user on whose behalf the message is being deleted.

.EXAMPLE
Remove-ZoomChatbotMessage -MessageId "msg123" -RobotJid "bot@xmpp.zoom.us" -AccountId "abc123"

.EXAMPLE
$msg | Remove-ZoomChatbotMessage

.EXAMPLE
Remove-ZoomChatbotMessage -MessageId "msg123" -RobotJid "bot@xmpp.zoom.us" -AccountId "abc123" -WhatIf

.LINK
https://developers.zoom.us/docs/api/rest/reference/chatbot/methods/#operation/deleteAChatbotMessage

#>

function Remove-ZoomChatbotMessage {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Medium')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('message_id', 'id')]
        [string]$MessageId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('robot_jid')]
        [string]$RobotJid,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [Alias('account_id')]
        [string]$AccountId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('user_jid')]
        [string]$UserJid
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/chat/messages/$MessageId"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('robot_jid', $RobotJid)
        $query.Add('account_id', $AccountId)

        if ($PSBoundParameters.ContainsKey('UserJid')) {
            $query.Add('user_jid', $UserJid)
        }

        $Request.Query = $query.ToString()

        if ($PSCmdlet.ShouldProcess($MessageId, 'Delete chatbot message')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Delete

            Write-Output $response
        }
    }
}
