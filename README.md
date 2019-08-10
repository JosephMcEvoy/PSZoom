# Powershell Zoom Wrapper #
- - - - 
A Powershell wrapper to interface with the Zoom Api (Zoom Video Communications). 

# Getting Started #
## Using PowershellGallery ##
```
Install-Module PSZoom
Import-Module PSZoom
```

## Using Git ##
```
git clone "https://github.com/JosephMcEvoy/PSZoom.git"
Place directory into a module directory (use $env:PSModulePath to find valid paths).
Import-Module PSZoom
```

# Using your API Key and API Secret #
All commands require an API Key and Api Secret. For ease of use, each command looks for these variables
automatically in the following order:
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
