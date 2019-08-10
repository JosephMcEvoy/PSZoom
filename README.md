# Powershell Zoom Wrapper #
- - - - 
A collection of Powershell tools to interface with the Zoom Api (Zoom Video Communications). 

# Getting Started #
## Using PowershellGallery ##
```
Install-Module ZoomWrapper
Import-Module ZoomWrapper
```

## Using Git ##
```
git clone "https://github.com/JosephMcEvoy/PowerShell-Zoom-Wrapper.git"
Import-Module '.\ZoomWrapper\ZoomWrapper.psm1'
```

# Using your API Key and API Secret #
All commands require an API Key and Api Secret. For ease of use, each command looks for these variables
automatically in the following order:
    In the global scope for ZoomApiKey and ZoomApiSecret 
    As passed as parameters to the command
    As an AutomationVariable
    A prompt to host to enter Key/Secret manually

# Example #
```
#requires ZoomWrapper
$Global:ZoomApiKey    = 'API_Key_Goes_Here'  
$Global:ZoomApiSecret = 'API_Secret_Goes_Here'  
Get-ZoomMeeting 123456789
```
