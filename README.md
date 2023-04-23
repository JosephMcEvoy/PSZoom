[![Build status](https://ci.appveyor.com/api/projects/status/e7svaoe2hmlrrnje?svg=true)](https://ci.appveyor.com/project/JosephMcEvoy/pszoom)

# Update - PSZoom 2.0 #
PSZoom is ending support for JWT. As of 2.0 only Server-to-Server OAuth is supported. JWT authorization is supported in versions prior to 2.0. If you are using JWT, you should update your code to support Server-To-Server Oauth. Zoom will be dropping support of JWT in June of 2023.
  
A new cmdlet, Connect-PSZoom, must be run before using any other PSZoom cmdlets. This change, along with the dropping of support for JWT, means that old scripts will not work with this version. Instead of declaring variables such as ZoomApiKey and ZoomApiSecret, you should use Connect-PSZoom. 

You can read more about JWT deprecation at [https://marketplace.zoom.us/docs/guides/build/jwt-app/jwt-faq/](https://marketplace.zoom.us/docs/guides/build/jwt-app/jwt-faq/) and more about a Zoom server-to-server Oauth app at [https://marketplace.zoom.us/docs/guides/build/server-to-server-oauth-app/](https://marketplace.zoom.us/docs/guides/build/server-to-server-oauth-app/).

# PSZoom #
- - - - 
PSZoom is a Powershell wrapper to interface with Zoom's API (Zoom Video Communications). The module wraps many API calls from Zoom's API v2 documentation. You can find Zoom's documentation at https://marketplace.zoom.us/docs/api-reference/zoom-api. PSZoom is not an official module.

Cmdlets are named with approved Powershell verbs but keeping to as close to Zoom's API reference as possible. For example, Zoom has two API calls that they named "List User Assistants" and "Update Zoom Meeting". In PSZoom they are named Get-ZoomUserAssistants and Update-ZoomMeeting, respectively. In general, each cmdlet has associated help which includes a link (found under .LINK) to the API call that it is wrapping.  
  
Zoom has a rate limit that varies depending on your account and the type of request. If you're making too many requests, the cmdlet will automatically retry after one second.

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
All commands require a Client ID and Client Secret. As of PSZoom 2.0, PSZoom only supports Server-to-Server OAuth authorization. You can generate the Server-to-Server OAuth key/secret from https://marketplace.zoom.us/develop/create, then click on  'Create' under Server-to-Server OAuth.  
  

# Example script #
```
import-module PSZoom
Connect-PSZoom -AccountID 'account_id' -ClientID 'client_id' -ClientSecret 'secret'
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
Show-ZoomRecordings

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
Get-ZoomPastMeetingParticipantsMetrics  
Get-ZoomPersonalMeetingRoomName  
New-ZoomMeeting  
New-ZoomMeetingPoll  
New-ZoomMeetingPollQuestion  
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
  
## Phones ##  
Add-ZoomPhoneUserCallingPlans
Add-ZoomPhoneUserNumber
Get-ZoomPhoneCallingPlans
Get-ZoomPhoneNumber  
Get-ZoomPhoneSettingTemplate  
Get-ZoomPhoneSettingTemplates  
Get-ZoomPhoneUser  
Get-ZoomPhoneUsers  
Get-ZoomPhoneUserSettings
Remove-ZoomPhoneUserCallingPlan
Remove-ZoomPhoneUserNumber
Update-ZoomPhoneUserCallingPlan  

## Phone Sites ##  
Get-ZoomPhoneSite  
Get-ZoomPhoneSites  
  
## Reports ##
Get-ZoomActiveInactiveHostReports  
Get-ZoomDailyUsageReport  
Get-ZoomMeetingParticipantsReport  
Get-ZoomRegistrationQuestions  
Get-ZoomTelephoneReports  
Get-ZoomWebinarDetailsReport  
Get-ZoomWebinarParticipantsReport  
  
## Rooms ##  
Get-ZoomRooms  
Get-ZoomRoomsDashboard  
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
Invoke-ZoomRetMethod  
Join-ZoomPages  
New-ZoomApiToken  
  
# Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/FeatureName`)
3. Commit your Changes (`git commit -m 'Add some Feature'`)
4. Push to the Branch (`git push origin feature/FeatureName`)
5. Open a Pull Request
