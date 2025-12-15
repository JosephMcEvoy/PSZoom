[![Test Suite](https://github.com/JosephMcEvoy/PSZoom/actions/workflows/test.yml/badge.svg)](https://github.com/JosephMcEvoy/PSZoom/actions/workflows/test.yml)

# PSZoom #
PSZoom is a Powershell wrapper to interface with Zoom's API (Zoom Video Communications). The module wraps many API calls from Zoom's API v2 documentation. You can find Zoom's documentation at https://marketplace.zoom.us/docs/api-reference/zoom-api. PSZoom is not an official module.

Cmdlets are named with approved Powershell verbs but keeping to as close to Zoom's API reference as possible. For example, Zoom has two API calls that they named "List User Assistants" and "Update Zoom Meeting". In PSZoom they are named Get-ZoomUserAssistants and Update-ZoomMeeting, respectively. In general, each cmdlet has associated help which includes a link (found under .LINK) to the API call that it is wrapping.  
  
Zoom has a rate limit that varies depending on your account and the type of request. If you're making too many requests, the cmdlet will automatically retry after one second.

## Getting started ##
### Using PowershellGallery ###
```
Install-Module PSZoom
Import-Module PSZoom
```

### Using Git ###
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

## Using your API key and API secret ##
All commands require a Client ID and Client Secret. As of PSZoom 2.0, PSZoom only supports Server-to-Server OAuth authorization. You can generate the Server-to-Server OAuth key/secret from https://marketplace.zoom.us/develop/create, then click on  'Create' under Server-to-Server OAuth.  
  

## Example script ##
```
import-module PSZoom
Connect-PSZoom -AccountID 'account_id' -ClientID 'client_id' -ClientSecret 'secret'
Get-ZoomMeeting 123456789
```

## Available functions ##
Use get-help for more information about each function.

### Accounts ###
Add-ZoomAccountAddonPlan
Get-ZoomAccount
Get-ZoomAccountBilling
Get-ZoomAccountManagedDomains
Get-ZoomAccountPlans
Get-ZoomAccounts
Get-ZoomAccountSettings
Get-ZoomPhoneAccountSettings
Get-ZoomPhoneOutboundCallerIdCustomizedNumber
New-ZoomAccount
New-ZoomAccountPlan
New-ZoomPhoneOutboundCallerIdCustomizedNumber
Remove-ZoomAccount
Remove-ZoomPhoneOutboundCallerIdCustomizedNumber
Update-ZoomAccountAddonPlan
Update-ZoomAccountBasePlan
Update-ZoomAccountBilling
Update-ZoomAccountOptions
Update-ZoomAccountSettings

### Cloud Recordings ###
Get-ZoomAccountRecordings  
Get-ZoomAccountRecordings  
Get-ZoomMeetingCloudRecordings  
Remove-ZoomMeetingRecordingFile  
Remove-ZoomMeetingRecordings  
Show-ZoomRecordings

### Groups ###
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
  
### Meetings ###
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
  
### Phones ###  
Get-ZoomPhoneCallingPlan  
Get-ZoomPhoneNumber  
Get-ZoomPhoneProvisioingTemplate  
  
### Common Area Phones ###  
Add-ZoomPhoneCommonAreaCallingPlan  
Add-ZoomPhoneCommonAreaNumber  
Get-ZoomPhoneCommonArea  
Get-ZoomPhoneCommonAreaSettings  
New-ZoomPhoneCommonArea  
Remove-ZoomPhoneCommonArea  
Remove-ZoomPhoneCommonAreaCallingPlan  
Remove-ZoomPhoneCommonAreaNumber  
Update-ZoomPhoneCommonArea  
  
### Desk Phones ###  
Add-ZoomPhoneDeviceAssignee  
Get-ZoomPhoneDevice  
Invoke-ZoomPhoneDeviceReboot  
New-ZoomPhoneDevice  
Remove-ZoomPhoneDevice  
Remove-ZoomPhoneDeviceAssignee  
Update-ZoomPhoneDevice  
Update-ZoomPhoneDeviceProvisioningTemplate  
  
### User Phones ###  
Add-ZoomPhoneUserCallingPlan  
Add-ZoomPhoneUserNumber  
Get-ZoomPhoneUser  
Get-ZoomPhoneUserSettings  
New-ZoomPhoneUser  
Remove-ZoomPhoneUserCallingPlan  
Remove-ZoomPhoneUserNumber  
Update-ZoomPhoneUser  
Update-ZoomPhoneUserCallingPlan  
Update-ZoomPhoneUserSettings  
  
### Phone Sites ###  
Get-ZoomPhoneSite  
Get-ZoomPhoneSettingTemplate  
Get-ZoomPhoneSiteEmergencyAddress  
  
### Reports ###  
Get-ZoomActiveInactiveHostReports  
Get-ZoomDailyUsageReport  
Get-ZoomMeetingParticipantsReport  
Get-ZoomRegistrationQuestions  
Get-ZoomTelephoneReports  
Get-ZoomWebinarDetailsReport  
Get-ZoomWebinarParticipantsReport  
  
### Rooms ###  
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
  
### Users ###
Add-ZoomUserAssistants  
Get-ZoomUser  
Get-ZoomUserEmailStatus  
Get-ZoomUserPermissions  
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
  
### Webinars ###
Get-ZoomWebinar  
Get-ZoomWebinarsFromUser  
Get-ZoomWebinarPanelists  

### Utility ###
Invoke-ZoomRetMethod  
Join-ZoomPages  
New-ZoomApiToken  
  
## Contributing ##  

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/FeatureName`)
3. Commit your Changes (`git commit -m 'Add some Feature'`)
4. Push to the Branch (`git push origin feature/FeatureName`)
5. Open a Pull Request
