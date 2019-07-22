# Powershell Zoom Wrapper
A collection of Powershell tools to interface with the Zoom Api. 

# Setup
Clone project. 

# Using your API Key and API Secret
All of the wrapper functions will first look for the Key/Secret as passed as parameters.  
If not found it will look in ZoomModule.psm1. ZoomModule.psm1 can be edited to include API Key and API Secret. E.g.:  
$Global:ZoomApiKey    = '<API key>'  
$Global:ZoomApiSecret = '<API secret>'  
If the Key/Secret are not found in ZoomModule.psm1 then the user will be prompted to enter the credentials.
