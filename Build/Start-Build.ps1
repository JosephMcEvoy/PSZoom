<#
.SYNOPSIS
    Entry point for PSZoom build process.
.DESCRIPTION
    Installs required modules and invokes psake build tasks.
.PARAMETER Task
    Build task to run. Default: Default (runs all tasks)
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$Task = 'Default'
)

$ErrorActionPreference = 'Stop'

# Required modules with minimum versions
$requiredModules = @{
    'psake'    = '4.9.0'
    'PSDeploy' = '1.0.5'
    'Pester'   = '5.6.1'
}

Write-Host "=== Installing Build Dependencies ===" -ForegroundColor Cyan

foreach ($module in $requiredModules.GetEnumerator()) {
    $installed = Get-Module -Name $module.Key -ListAvailable |
        Where-Object { $_.Version -ge [version]$module.Value } |
        Select-Object -First 1

    if (-not $installed) {
        Write-Host "Installing $($module.Key) v$($module.Value)..."
        Install-Module -Name $module.Key -RequiredVersion $module.Value -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber
    } else {
        Write-Host "$($module.Key) v$($installed.Version) already installed"
    }

    Import-Module -Name $module.Key -MinimumVersion $module.Value -Force
}

Write-Host "`n=== Starting Build ===" -ForegroundColor Cyan

# Invoke psake
Invoke-psake "$PSScriptRoot\psake.ps1" -taskList $Task

# Check build result and exit with appropriate code
if ($psake.build_success -eq $true) {
    Write-Host "`n=== Build Completed Successfully ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n=== Build Failed ===" -ForegroundColor Red
    exit 1
}
