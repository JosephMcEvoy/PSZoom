<#

.SYNOPSIS
Edit a message sent by a Zoom Marketplace Chatbot app.

.DESCRIPTION
Updates an existing message sent by your Marketplace Chatbot app.
Requires a Zoom Marketplace Chatbot app with the imchat:bot OAuth scope.

.PARAMETER MessageId
The message ID of the message to edit.

.PARAMETER RobotJid
The Bot JID. You can find this value in the Feature section of your Marketplace Chatbot app.

.PARAMETER AccountId
The authorized account's account ID.

.PARAMETER Content
The updated message content as a hashtable. This should follow Zoom's message template format.

.PARAMETER UserJid
The JID of the user on whose behalf the message is being sent.

.PARAMETER IsMarkdownSupport
Enable Markdown parsing for the message content.

.EXAMPLE
$content = @{
    head = @{
        text = "Updated message"
    }
    body = @(
        @{
            type = "message"
            text = "This message has been edited"
        }
    )
}
Update-ZoomChatbotMessage -MessageId "msg123" -RobotJid "bot@xmpp.zoom.us" -AccountId "abc123" -Content $content

.EXAMPLE
$msg | Update-ZoomChatbotMessage -Content $newContent -IsMarkdownSupport

.LINK
https://developers.zoom.us/docs/api/rest/reference/chatbot/methods/#operation/editChatbotMessage

#>

function Update-ZoomChatbotMessage {
    [CmdletBinding()]
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

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 3
        )]
        [hashtable]$Content,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('user_jid')]
        [string]$UserJid,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('is_markdown_support')]
        [switch]$IsMarkdownSupport
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/chat/messages/$MessageId"

        $body = @{
            robot_jid  = $RobotJid
            account_id = $AccountId
            content    = $Content
        }

        if ($PSBoundParameters.ContainsKey('UserJid')) {
            $body.Add('user_jid', $UserJid)
        }

        if ($IsMarkdownSupport) {
            $body.Add('is_markdown_support', $true)
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Put

        Write-Output $response
    }
}
