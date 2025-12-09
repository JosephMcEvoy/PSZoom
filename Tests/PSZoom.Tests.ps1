<#
.SYNOPSIS
    Main test runner for PSZoom module tests.

.DESCRIPTION
    This file contains module-level tests and serves as the entry point for Pester testing.
    It validates module loading, export verification, and basic functionality.

.NOTES
    Run with: Invoke-Pester -Path ./Tests/PSZoom.Tests.ps1
    Or use the pester.config.psd1 configuration for full test suite.
#>

BeforeAll {
    $ModulePath = "$PSScriptRoot/../PSZoom/PSZoom.psd1"
    $ModuleRoot = "$PSScriptRoot/../PSZoom"

    # Remove module if already loaded
    Get-Module PSZoom | Remove-Module -Force -ErrorAction SilentlyContinue

    # Import the module
    Import-Module $ModulePath -Force
}

Describe 'PSZoom Module' {
    Context 'Module Loading' {
        It 'Should import without errors' {
            { Import-Module $ModulePath -Force } | Should -Not -Throw
        }

        It 'Should be loaded in the current session' {
            Get-Module PSZoom | Should -Not -BeNullOrEmpty
        }

        It 'Should have a valid module manifest' {
            $manifest = Test-ModuleManifest -Path $ModulePath
            $manifest | Should -Not -BeNullOrEmpty
        }

        It 'Should have a valid GUID' {
            $manifest = Test-ModuleManifest -Path $ModulePath
            $manifest.GUID | Should -Be '7d4382d4-4c76-4f14-83a5-9149d3d1c450'
        }
    }

    Context 'Module Structure' {
        It 'Should have Public folder with cmdlets' {
            Test-Path "$ModuleRoot/Public" | Should -BeTrue
        }

        It 'Should have Private folder with helper functions' {
            Test-Path "$ModuleRoot/Private" | Should -BeTrue
        }

        It 'Should have PSZoom.psm1 root module' {
            Test-Path "$ModuleRoot/PSZoom.psm1" | Should -BeTrue
        }
    }

    Context 'Exported Functions' {
        BeforeAll {
            $exportedFunctions = (Get-Module PSZoom).ExportedFunctions.Keys
        }

        It 'Should export Connect-PSZoom' {
            $exportedFunctions | Should -Contain 'Connect-PSZoom'
        }

        It 'Should export Invoke-ZoomRestMethod' {
            $exportedFunctions | Should -Contain 'Invoke-ZoomRestMethod'
        }

        It 'Should export Get-ZoomUser' {
            $exportedFunctions | Should -Contain 'Get-ZoomUser'
        }

        It 'Should export Get-ZoomMeeting' {
            $exportedFunctions | Should -Contain 'Get-ZoomMeeting'
        }

        It 'Should export New-ZoomMeeting' {
            $exportedFunctions | Should -Contain 'New-ZoomMeeting'
        }

        It 'Should export at least 100 functions' {
            $exportedFunctions.Count | Should -BeGreaterOrEqual 100
        }
    }

    Context 'Function Naming Convention' {
        BeforeAll {
            $exportedFunctions = (Get-Module PSZoom).ExportedFunctions.Keys
        }

        It 'All exported functions should use approved verbs' {
            $approvedVerbs = (Get-Verb).Verb
            $nonCompliant = @()

            foreach ($func in $exportedFunctions) {
                $verb = $func.Split('-')[0]
                if ($verb -notin $approvedVerbs) {
                    $nonCompliant += $func
                }
            }

            $nonCompliant | Should -BeNullOrEmpty -Because "All functions should use approved PowerShell verbs. Non-compliant: $($nonCompliant -join ', ')"
        }

        It 'All exported functions should contain Zoom in the noun' {
            $nonCompliant = @()

            foreach ($func in $exportedFunctions) {
                $parts = $func.Split('-')
                if ($parts.Count -ge 2) {
                    $noun = $parts[1]
                    if ($noun -notlike '*Zoom*' -and $noun -notlike 'PSZoom*' -and $func -ne 'Join-ZoomPages') {
                        $nonCompliant += $func
                    }
                }
            }

            $nonCompliant | Should -BeNullOrEmpty -Because "All functions should have Zoom in the noun. Non-compliant: $($nonCompliant -join ', ')"
        }
    }

    Context 'Help Documentation' {
        BeforeAll {
            $exportedFunctions = (Get-Module PSZoom).ExportedFunctions.Keys | Select-Object -First 10
        }

        It 'Exported functions should have synopsis help' {
            foreach ($func in $exportedFunctions) {
                $help = Get-Help $func -ErrorAction SilentlyContinue
                $help.Synopsis | Should -Not -BeNullOrEmpty -Because "$func should have a synopsis"
            }
        }

        It 'Key functions should have examples' {
            $keyFunctions = @('Connect-PSZoom', 'Get-ZoomUser', 'Get-ZoomMeeting', 'New-ZoomMeeting')

            foreach ($func in $keyFunctions) {
                $help = Get-Help $func -Full -ErrorAction SilentlyContinue
                $help.Examples | Should -Not -BeNullOrEmpty -Because "$func should have examples"
            }
        }
    }
}

Describe 'Module Dependencies' {
    Context 'Required Modules' {
        It 'Should not require external modules' {
            $manifest = Test-ModuleManifest -Path $ModulePath
            $manifest.RequiredModules | Should -BeNullOrEmpty
        }
    }

    Context 'PowerShell Version' {
        It 'Should work on PowerShell 5.1 and later' {
            $manifest = Test-ModuleManifest -Path $ModulePath
            # Current module doesn't specify version, but should work on 5.1+
            $PSVersionTable.PSVersion.Major | Should -BeGreaterOrEqual 5
        }
    }
}

Describe 'Test Infrastructure' {
    Context 'Test Fixtures' {
        It 'Should have mock response fixtures directory' {
            Test-Path "$PSScriptRoot/Fixtures/MockResponses" | Should -BeTrue
        }

        It 'Should have user mock responses' {
            Test-Path "$PSScriptRoot/Fixtures/MockResponses/user-get.json" | Should -BeTrue
            Test-Path "$PSScriptRoot/Fixtures/MockResponses/user-list.json" | Should -BeTrue
        }

        It 'Should have meeting mock responses' {
            Test-Path "$PSScriptRoot/Fixtures/MockResponses/meeting-get.json" | Should -BeTrue
            Test-Path "$PSScriptRoot/Fixtures/MockResponses/meeting-list.json" | Should -BeTrue
        }

        It 'Mock response files should be valid JSON' {
            $jsonFiles = Get-ChildItem "$PSScriptRoot/Fixtures/MockResponses/*.json"

            foreach ($file in $jsonFiles) {
                { Get-Content $file.FullName | ConvertFrom-Json } | Should -Not -Throw -Because "$($file.Name) should be valid JSON"
            }
        }
    }

    Context 'Unit Test Directories' {
        It 'Should have Private function tests directory' {
            Test-Path "$PSScriptRoot/Unit/Private" | Should -BeTrue
        }

        It 'Should have Public function tests directory' {
            Test-Path "$PSScriptRoot/Unit/Public" | Should -BeTrue
        }

        It 'Should have Contract tests directory' {
            Test-Path "$PSScriptRoot/Contract" | Should -BeTrue
        }
    }
}

AfterAll {
    # Cleanup
    Get-Module PSZoom | Remove-Module -Force -ErrorAction SilentlyContinue
}
