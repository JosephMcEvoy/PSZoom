# Chatbot API Cmdlets Design

**Date:** 2025-12-16
**Status:** Approved
**Category:** New API Coverage

## Overview

Add 4 new cmdlets to support Zoom Marketplace Chatbot API endpoints. This is the first step in a "least to most" approach to expanding PSZoom's API coverage.

## API Endpoints

| Endpoint | Method | Cmdlet |
|----------|--------|--------|
| `/im/chat/messages` | POST | Send-ZoomChatbotMessage |
| `/im/chat/messages/{message_id}` | PUT | Update-ZoomChatbotMessage |
| `/im/chat/messages/{message_id}` | DELETE | Remove-ZoomChatbotMessage |
| `/im/chat/users/{userId}/unfurls/{triggerId}` | POST | Send-ZoomChatbotUnfurl |

## File Structure

```
PSZoom/Public/Chatbot/
├── Send-ZoomChatbotMessage.ps1
├── Update-ZoomChatbotMessage.ps1
├── Remove-ZoomChatbotMessage.ps1
└── Send-ZoomChatbotUnfurl.ps1

Tests/Unit/Public/Chatbot/
├── Send-ZoomChatbotMessage.Tests.ps1
├── Update-ZoomChatbotMessage.Tests.ps1
├── Remove-ZoomChatbotMessage.Tests.ps1
└── Send-ZoomChatbotUnfurl.Tests.ps1
```

## Parameter Design

### Send-ZoomChatbotMessage

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| RobotJid | string | Yes | Bot's JID identifier |
| ToJid | string | Yes | Recipient channel/user JID |
| AccountId | string | Yes | Authorized account ID |
| UserJid | string | Yes | Sender's JID |
| Content | hashtable | Yes | Message template object |
| VisibleToUser | string | No | User ID for targeted visibility |
| ReplyTo | string | No | Parent message ID for threading |
| IsMarkdownSupport | switch | No | Enable Markdown parsing |

### Update-ZoomChatbotMessage

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| MessageId | string | Yes (Pipeline) | Message to edit |
| RobotJid | string | Yes | Bot's JID |
| AccountId | string | Yes | Account ID |
| Content | hashtable | Yes | Updated message content |
| UserJid | string | No | Sender's JID |
| IsMarkdownSupport | switch | No | Enable Markdown |

### Remove-ZoomChatbotMessage

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| MessageId | string | Yes (Pipeline) | Message to delete |
| RobotJid | string | Yes | Bot's JID |
| AccountId | string | Yes | Account ID |
| UserJid | string | No | Sender's JID |

### Send-ZoomChatbotUnfurl

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| UserId | string | Yes | User identifier |
| TriggerId | string | Yes | Unfurl request ID |
| Content | string | Yes | JSON template for link preview |

## Implementation Details

### API Base Path
```
https://api.$ZoomURI/v2/im/chat/messages
```

### Request Body Handling
- Convert `Content` hashtable to JSON via `ConvertTo-Json -Depth 10`
- Build body hashtable with required fields, conditionally add optional fields
- Pass to `Invoke-ZoomRestMethod -Body $body -Method Post`

### Response Handling
- Send returns: `message_id`, `robot_jid`, `sent_time`, `to_jid`, `user_jid`
- Update returns: same as Send
- Remove returns: deleted message object
- Unfurl returns: nothing (204 No Content)

### Pipeline Support
```powershell
$msg = Send-ZoomChatbotMessage -RobotJid $bot -ToJid $channel ...
$msg | Update-ZoomChatbotMessage -Content $newContent ...
$msg | Remove-ZoomChatbotMessage
```

### ShouldProcess
- `Remove-ZoomChatbotMessage` supports `-WhatIf` and `-Confirm`

## Testing

- Unit tests mock `Invoke-ZoomRestMethod` responses
- Test parameter validation, pipeline input, optional parameter handling
- Test ShouldProcess behavior for Remove cmdlet

## Module Updates

- Add 4 functions to `FunctionsToExport` in `PSZoom.psd1`

## Prerequisites

Users need:
- Zoom Marketplace Chatbot app credentials
- `imchat:bot` OAuth scope configured

## References

- [Zoom Chatbot API](https://developers.zoom.us/docs/api/rest/reference/chatbot/methods/)
