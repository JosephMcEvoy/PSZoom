param($Task = 'Default')
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module 'Psake', 'PSDeploy', 'Pester', 'BuildHelpers'
Import-Module 'Psake', 'PSDeploy', 'Pester', 'BuildHelpers' 

Set-BuildEnvironment

Invoke-psake .\psake.ps1 -taskList $Task -nologo
exit ( [int]( -not $psake.build_success ) )