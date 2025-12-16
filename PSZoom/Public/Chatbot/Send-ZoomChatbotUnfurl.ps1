<#

.SYNOPSIS
Unfurl a link with a Zoom Marketplace Chatbot app.

.DESCRIPTION
Sends a link unfurl (preview) response from your Marketplace Chatbot app.
This is used to provide rich previews when links are shared in Zoom Team Chat.
Requires a Zoom Marketplace Chatbot app with the imchat:bot OAuth scope.

.PARAMETER UserId
The unique identifier of the user.

.PARAMETER TriggerId
The unfurl request trigger ID provided by Zoom when a link is detected.

.PARAMETER Content
The JSON template content for the link preview. This should follow Zoom's unfurl template format.

.EXAMPLE
$unfurlContent = @{
    title = "Example Page"
    description = "This is a preview of the linked page"
    image = "https://example.com/preview.png"
}
Send-ZoomChatbotUnfurl -UserId "user123" -TriggerId "trigger456" -Content ($unfurlContent | ConvertTo-Json)

.EXAMPLE
Send-ZoomChatbotUnfurl -UserId $userId -TriggerId $triggerId -Content $jsonContent

.LINK
https://developers.zoom.us/docs/api/rest/reference/chatbot/methods/#operation/unfurlingLink

#>

function Send-ZoomChatbotUnfurl {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('user_id', 'id')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('trigger_id')]
        [string]$TriggerId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [string]$Content
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/im/chat/users/$UserId/unfurls/$TriggerId"

        $body = @{
            content = $Content
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $body -Method Post

        # API returns 204 No Content on success, so response may be empty
        if ($null -eq $response) {
            Write-Output $true
        } else {
            Write-Output $response
        }
    }
}
