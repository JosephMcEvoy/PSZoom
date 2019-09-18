Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

if(-not (Get-Module -ListAvailable PSDepend)) {
    install-module psdepend
}

Import-Module PSDepend
$null = Invoke-PSDepend -Path "$PSScriptRoot\build.requirements.psd1" -Install -Import -Force

Set-BuildEnvironment -Force -Path $PSScriptRoot\..

Invoke-psake $PSScriptRoot\psake.ps1 -nologo
exit ( [int]( -not $psake.build_success ) )