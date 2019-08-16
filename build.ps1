#Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
#Install-Module -name ('Psake', 'PSDeploy', 'Pester', 'BuildHelpers') -Force
#Import-Module -name ('Psake', 'PSDeploy', 'Pester', 'BuildHelpers') -Force
Set-BuildEnvironment -BuildOutput '.\'
Get-BuildEnvironment