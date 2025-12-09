BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-ZoomTimeZones' {
    Context 'When retrieving timezone mappings' {
        BeforeAll {
            $result = Get-ZoomTimeZones
        }

        It 'Should return a hashtable' {
            $result | Should -BeOfType [hashtable]
        }

        It 'Should contain timezone entries' {
            $result.Count | Should -BeGreaterThan 100
        }

        It 'Should contain UTC timezone' {
            $result.Keys | Should -Contain 'UTC'
        }

        It 'Should map UTC to Universal Time UTC' {
            $result['UTC'] | Should -Be 'Universal Time UTC'
        }
    }

    Context 'US timezone mappings' {
        BeforeAll {
            $result = Get-ZoomTimeZones
        }

        It 'Should contain Pacific timezone' {
            $result.Keys | Should -Contain 'America/Los_Angeles'
            $result['America/Los_Angeles'] | Should -Be 'Pacific Time (US and Canada)'
        }

        It 'Should contain Mountain timezone' {
            $result.Keys | Should -Contain 'America/Denver'
            $result['America/Denver'] | Should -Be 'Mountain Time (US and Canada)'
        }

        It 'Should contain Central timezone' {
            $result.Keys | Should -Contain 'America/Chicago'
            $result['America/Chicago'] | Should -Be 'Central Time (US and Canada)'
        }

        It 'Should contain Eastern timezone' {
            $result.Keys | Should -Contain 'America/New_York'
            $result['America/New_York'] | Should -Be 'Eastern Time (US and Canada)'
        }

        It 'Should contain Hawaii timezone' {
            $result.Keys | Should -Contain 'Pacific/Honolulu'
            $result['Pacific/Honolulu'] | Should -Be 'Hawaii'
        }

        It 'Should contain Alaska timezone' {
            $result.Keys | Should -Contain 'America/Anchorage'
            $result['America/Anchorage'] | Should -Be 'Alaska'
        }
    }

    Context 'International timezone mappings' {
        BeforeAll {
            $result = Get-ZoomTimeZones
        }

        It 'Should contain London timezone' {
            $result.Keys | Should -Contain 'Europe/London'
            $result['Europe/London'] | Should -Be 'London'
        }

        It 'Should contain Tokyo timezone' {
            $result.Keys | Should -Contain 'Asia/Tokyo'
        }

        It 'Should contain Sydney timezone' {
            $result.Keys | Should -Contain 'Australia/Sydney'
        }

        It 'Should contain Hong Kong timezone' {
            $result.Keys | Should -Contain 'Asia/Hong_Kong'
            $result['Asia/Hong_Kong'] | Should -Be 'Hong Kong'
        }

        It 'Should contain Singapore timezone' {
            $result.Keys | Should -Contain 'Asia/Singapore'
            $result['Asia/Singapore'] | Should -Be 'Singapore'
        }
    }

    Context 'Timezone lookup validation' {
        BeforeAll {
            $result = Get-ZoomTimeZones
        }

        It 'Should allow checking if timezone exists using Contains method' {
            $result.Keys -contains 'Pacific/Midway' | Should -BeTrue
        }

        It 'Should return false for non-existent timezone' {
            $result.Keys -contains 'Invalid/Timezone' | Should -BeFalse
        }
    }
}
