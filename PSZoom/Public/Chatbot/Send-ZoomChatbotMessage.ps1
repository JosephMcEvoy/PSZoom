<#

.SYNOPSIS
Send a message from a Zoom Marketplace Chatbot app.

.DESCRIPTION
Sends messages from your Marketplace Chatbot app to a channel or user.
Requires a Zoom Marketplace Chatbot app with the imchat:bot OAuth scope.

.PARAMETER RobotJid
The Bot JID. You can find this value in the Feature section of your Marketplace Chatbot app.

.PARAMETER ToJid
The JID of the channel or user to send the message to.

.PARAMETER AccountId
The authorized account's account ID.

.PARAMETER UserJid
The JID of the user on whose behalf the message is being sent.

.PARAMETER Content
The message content as a hashtable. This should follow Zoom's message template format.

.PARAMETER VisibleToUser
The user ID to make this message visible only to a specific user in a channel.

.PARAMETER ReplyTo
The message ID to reply to for threading messages.

.PARAMETER IsMarkdownSupport
Enable Markdown parsing for the message content.

.EXAMPLE
$content = @{
    head = @{
        text = "Hello from Chatbot"
    }
    body = @(
        @{
            type = "message"
            text = "This is a test message"
        }
    )
}
Send-ZoomChatbotMessage -RobotJid "bot@xmpp.zoom.us" -ToJid "channel@conference.xmpp.zoom.us" -AccountId "abc123" -UserJid "user@xmpp.zoom.us" -Content $content

.EXAMPLE
Send-ZoomChatbotMessage -RobotJid $botJid -ToJid $channelJid -AccountId $accountId -UserJid $userJid -Content $content -IsMarkdownSupport

.LINK
https://developers.zoom.us/docs/api/rest/reference/chatbot/methods/#operation/sendChatbot

#>

function Send-ZoomChatbotMessage {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('robot_jid')]
        [string]$RobotJid,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('to_jid')]
        [string]$ToJid,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [Alias('account_id')]
        [string]$AccountId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 3
        )]
        [Alias('user_jid')]
        [string]$UserJid,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 4
        )]
        [hashtable]$Content,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('visible_to_user')]
        [string]$VisibleToUser,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('reply_to')]
        [string]$ReplyTo,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('is_markdown_support')]
        [switch]$IsMarkdownSupport
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/chat/messages"

        $body = @{
            robot_jid  = $RobotJid
            to_jid     = $ToJid
            account_id = $AccountId
            user_jid   = $UserJid
            content    = $Content
        }

        if ($PSBoundParameters.ContainsKey('VisibleToUser')) {
            $body.Add('visible_to_user', $VisibleToUser)
        }

        if ($PSBoundParameters.ContainsKey('ReplyTo')) {
            $body.Add('reply_to', $ReplyTo)
        }

        if ($IsMarkdownSupport) {
            $body.Add('is_markdown_support', $true)
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Post

        Write-Output $response
    }
}
