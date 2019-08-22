param(
    $Task = 'Default'
)
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module 'Psake', 'PSDeploy', 'Pester', 'BuildHelpers' -force
Import-Module 'Psake', 'BuildHelpers'

Set-BuildEnvironment

Invoke-psake .\psake.ps1 -taskList $Task -nologo
exit ( [int]( -not $psake.build_success ) )