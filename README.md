# PSZoom #
- - - - 
PSZoom is a Powershell wrapper to interface with the Zoom Api (Zoom Video Communications). 

# Getting Started #
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

# Using your API Key and API Secret #
All commands require an API key and API secret. Currently PSZoom uses only JWT for authorization.  
You can generate the JWT key/secret from https://marketplace.zoom.us/develop/create, then click on  
'Create' under JWT.  Note that in addition to the key/secret, Zoom also provides an IM Chat History
Token, this is not to be confused with the key/secret.
  
For ease of use, each command looks for these variables automatically in the following order:  
    In the global scope for ZoomApiKey and ZoomApiSecret  
    As passed as parameters to the command  
    As an AutomationVariable  
    A prompt to host to enter Key/Secret manually  

# Example Script #
```
import-module PSZoom
$Global:ZoomApiKey    = 'API_Key_Goes_Here'  
$Global:ZoomApiSecret = 'API_Secret_Goes_Here'  
Get-ZoomMeeting 123456789
```
