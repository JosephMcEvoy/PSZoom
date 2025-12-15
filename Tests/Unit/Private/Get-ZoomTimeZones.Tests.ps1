BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-ZoomTimeZones' {
    Context 'When retrieving timezone mappings' {
        It 'Should return a hashtable' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result | Should -BeOfType [hashtable]
            }
        }

        It 'Should contain timezone entries' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Count | Should -BeGreaterThan 100
            }
        }

        It 'Should contain UTC timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'UTC'
            }
        }

        It 'Should map UTC to Universal Time UTC' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result['UTC'] | Should -Be 'Universal Time UTC'
            }
        }
    }

    Context 'US timezone mappings' {
        It 'Should contain Pacific timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'America/Los_Angeles'
                $result['America/Los_Angeles'] | Should -Be 'Pacific Time (US and Canada)'
            }
        }

        It 'Should contain Mountain timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'America/Denver'
                $result['America/Denver'] | Should -Be 'Mountain Time (US and Canada)'
            }
        }

        It 'Should contain Central timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'America/Chicago'
                $result['America/Chicago'] | Should -Be 'Central Time (US and Canada)'
            }
        }

        It 'Should contain Eastern timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'America/New_York'
                $result['America/New_York'] | Should -Be 'Eastern Time (US and Canada)'
            }
        }

        It 'Should contain Hawaii timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'Pacific/Honolulu'
                $result['Pacific/Honolulu'] | Should -Be 'Hawaii'
            }
        }

        It 'Should contain Alaska timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'America/Anchorage'
                $result['America/Anchorage'] | Should -Be 'Alaska'
            }
        }
    }

    Context 'International timezone mappings' {
        It 'Should contain London timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'Europe/London'
                $result['Europe/London'] | Should -Be 'London'
            }
        }

        It 'Should contain Tokyo timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'Asia/Tokyo'
            }
        }

        It 'Should contain Sydney timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'Australia/Sydney'
            }
        }

        It 'Should contain Hong Kong timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'Asia/Hong_Kong'
                $result['Asia/Hong_Kong'] | Should -Be 'Hong Kong'
            }
        }

        It 'Should contain Singapore timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys | Should -Contain 'Asia/Singapore'
                $result['Asia/Singapore'] | Should -Be 'Singapore'
            }
        }
    }

    Context 'Timezone lookup validation' {
        It 'Should allow checking if timezone exists using Contains method' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys -contains 'Pacific/Midway' | Should -BeTrue
            }
        }

        It 'Should return false for non-existent timezone' {
            InModuleScope PSZoom {
                $result = Get-ZoomTimeZones
                $result.Keys -contains 'Invalid/Timezone' | Should -BeFalse
            }
        }
    }
}
