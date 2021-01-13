# PSZoom #
- - - - 
PSZoom is a Powershell wrapper to interface with Zoom's API (Zoom Video Communications). The module wraps many API calls from Zoom's API v2 documentation. You can find Zoom's documentation at https://marketplace.zoom.us/docs/api-reference/zoom-api. PSZoom is not an official module.

Cmdlets are named with approved Powershell verbs but keeping to as close to Zoom's API reference as possible. For example, Zoom has two API calls that they named "List User Assistants" and "Update Zoom Meeting". In PSZoom they are named Get-ZoomUserAssistants and Update-ZoomMeeting, respectively. In general, each cmdlet has associated help which includes a link (found under .LINK) to the API call that it is wrapping.  
  
Zoom has a rate limit that varies depending on your account and the type of request. Rate limiting / monitoring is not built into PSZoom at this time.  
  
# Getting started #
## Using PowershellGallery ##
```
Install-Module PSZoom
Import-Module PSZoom
```

## Using Git ##
Clone the repository.
```
git clone "https://github.com/JosephMcEvoy/PSZoom.git"
```
Place directory into a module directory (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules).
```
Move-Item -path ".\pszoom\pszoom" -Destination "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
```
Import the module.
```
Import-Module PSZoom
```

# Using your API key and API secret #
All commands require an API key and API secret. Currently PSZoom uses only JWT for authorization.  You can generate 
the JWT key/secret from https://marketplace.zoom.us/develop/create, then click on  'Create' under JWT.  Note that in 
addition to the key/secret, Zoom also provides an IM Chat History Token, this is not to be confused with the key/secret.  
  
For ease of use, each command looks for these variables automatically in the following order:  
    In the global scope for ZoomApiKey and ZoomApiSecret  
    As passed as parameters to the command  
    As an AutomationVariable  
    A prompt to host to enter Key/Secret manually  

# Example script #
```
import-module PSZoom
$Global:ZoomApiKey    = 'API_Key_Goes_Here'  
$Global:ZoomApiSecret = 'API_Secret_Goes_Here'  
Get-ZoomMeeting 123456789
```

# Available functions #
Use get-help for more information about each function.



## Cloud Recordings ##
Get-ZoomAccountRecordings  
Get-ZoomAccountRecordings  
Get-ZoomMeetingCloudRecordings  
Remove-ZoomMeetingRecordingFile  
Remove-ZoomMeetingRecordings  

## Groups ##
Add-ZoomGroupMember  
Get-ZoomGroup  
Get-ZoomGroupLockSettings  
Get-ZoomGroupMembers  
Get-ZoomGroups  
Get-ZoomGroupSettings  
New-ZoomGroup  
Remove-ZoomGroup  
Remove-ZoomGroupMembers  
Update-ZoomGroup  
Update-ZoomGroupLockSettings  
Update-ZoomGroupSettings  
  
## Meetings ##
Add-ZoomRegistrant  
Get-ZoomEndedMeetingInstances  
Get-ZoomMeeting  
Get-ZoomMeetingCloudRecordings  
Get-ZoomMeetingInvitation  
Get-ZoomMeetingPoll  
Get-ZoomMeetingPolls  
Get-ZoomMeetingRegistrants  
Get-ZoomMeetingsFromUser  
Get-ZoomPastMeetingDetails  
Get-ZoomPastMeetingParticipants  
Get-ZoomPersonalMeetingRoomName  
New-ZoomMeeting  
New-ZoomMeetingPoll  
Remove-ZoomMeeting  
Remove-ZoomMeetingPoll  
Update-MeetingStatus  
Update-ZoomMeeting  
Update-ZoomMeetingLiveStream  
Update-ZoomMeetingLiveStream  
Update-ZoomMeetingLiveStreamStatus  
Update-ZoomMeetingPoll  
Update-ZoomMeetingRegistrantStatus  
Update-ZoomMeetingRegistrationQuestions  
Update-ZoomMeetingStatus  
  
## Reports ##
Get-ZoomActiveInactiveHostReports  
Get-ZoomDailyUsageReport  
Get-ZoomMeetingParticipantsReport  
Get-ZoomRegistrationQuestions  
Get-ZoomTelephoneReports  
Get-ZoomWebinarDetailsReport  
Get-ZoomWebinarParticipantsReport  
  
## Rooms ##
Get-DashboardZoomRooms  
Get-ZoomRooms  
Get-ZoomRoomDevices  
Get-ZoomRoomLocations  
Disconnect-ZoomRoomMeeting  
New-ZoomRoomInvite  
New-ZoomRoomMeeting  
Remove-ZoomRoomMeeting  
Restart-ZoomRoom  
Remove-ZoomRoomMeeting  
Stop-ZoomRoomMeeting  
  
## Users ##
Add-ZoomUserAssistants  
Get-ZoomUser  
Get-ZoomUserEmailStatus  
Get-ZoomUserPermissions  
Get-ZoomUsers  
Get-ZoomUserSchedulers  
Get-ZoomUserSettings  
Get-ZoomUserToken  
New-ZoomUser  
Remove-ZoomSpecificUserAssistant  
Remove-ZoomSpecificUserScheduler  
Remove-ZoomUser  
Remove-ZoomUserAssistants  
Remove-ZoomUserSchedulers  
Revoke-ZoomUserSsoToken  
Update-ZoomProfilePicture  
Update-ZoomUser  
Update-ZoomUserEmail  
Update-ZoomUserpassword  
Update-ZoomUserSettings  
Update-ZoomUserStatus  
  
## Webinars ##
Get-ZoomWebinar  
Get-ZoomWebinarsFromUser  
Get-ZoomWebinarPanelists  

## Utility ##
New-ZoomApiToken  
  
# Note about Rate Limiting #
Zoom has a rate limit that varies depending on your account and the type of request. Rate limiting / monitoring is not built into PSZoom at this time.
