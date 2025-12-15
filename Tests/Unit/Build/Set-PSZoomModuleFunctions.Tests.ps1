# Tests/Unit/Build/Set-PSZoomModuleFunctions.Tests.ps1
BeforeAll {
    $script:BuildPrivatePath = Join-Path $PSScriptRoot '../../../Build/Private'
    . (Join-Path $BuildPrivatePath 'Set-PSZoomModuleFunctions.ps1')
}

Describe 'Set-PSZoomModuleFunctions' {
    Context 'When updating module manifest' {
        BeforeAll {
            # Create a temp manifest for testing
            $script:TempDir = Join-Path $TestDrive 'TestModule'
            New-Item -ItemType Directory -Path $TempDir -Force
            New-Item -ItemType Directory -Path (Join-Path $TempDir 'Public') -Force

            # Create test functions
            @'
function Get-TestFunction1 { }
'@ | Set-Content (Join-Path $TempDir 'Public/Get-TestFunction1.ps1')

            @'
function Get-TestFunction2 { }
'@ | Set-Content (Join-Path $TempDir 'Public/Get-TestFunction2.ps1')

            # Create root module file (required by Update-ModuleManifest)
            '' | Set-Content (Join-Path $TempDir 'TestModule.psm1')

            # Create minimal manifest
            New-ModuleManifest -Path (Join-Path $TempDir 'TestModule.psd1') -RootModule 'TestModule.psm1' -FunctionsToExport @()
        }

        It 'Should update FunctionsToExport in manifest' {
            $manifestPath = Join-Path $TempDir 'TestModule.psd1'
            Set-PSZoomModuleFunctions -ManifestPath $manifestPath -PublicPath (Join-Path $TempDir 'Public')

            $manifest = Import-PowerShellDataFile -Path $manifestPath
            $manifest.FunctionsToExport | Should -Contain 'Get-TestFunction1'
            $manifest.FunctionsToExport | Should -Contain 'Get-TestFunction2'
        }
    }
}
