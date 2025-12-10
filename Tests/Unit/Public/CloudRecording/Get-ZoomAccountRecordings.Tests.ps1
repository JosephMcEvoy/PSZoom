BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:MockRecordingList = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/recording-list.json" | ConvertFrom-Json
}

Describe 'Get-ZoomAccountRecordings' {
    Context 'When retrieving account recordings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should return recording list' {
            $result = Get-ZoomAccountRecordings -AccountId 'me'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return meetings array' {
            $result = Get-ZoomAccountRecordings -AccountId 'me'
            $result.meetings | Should -Not -BeNullOrEmpty
        }

        It 'Should return total_records count' {
            $result = Get-ZoomAccountRecordings -AccountId 'me'
            $result.total_records | Should -BeGreaterOrEqual 1
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct account recordings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/accounts/.*/recordings'
                return $script:MockRecordingList
            }

            Get-ZoomAccountRecordings -AccountId 'me'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockRecordingList
            }

            Get-ZoomAccountRecordings -AccountId 'me'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -PageSize 50 } | Should -Not -Throw
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomAccountRecordings -AccountId 'me' -PageSize 0 } | Should -Throw
            { Get-ZoomAccountRecordings -AccountId 'me' -PageSize 301 } | Should -Throw
        }

        It 'Should accept NextPageToken parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -NextPageToken 'abc123' } | Should -Not -Throw
        }
    }

    Context 'Date range parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept From parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -From '2024-01-01' } | Should -Not -Throw
        }

        It 'Should accept To parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -To '2024-01-31' } | Should -Not -Throw
        }

        It 'Should accept both From and To parameters' {
            { Get-ZoomAccountRecordings -AccountId 'me' -From '2024-01-01' -To '2024-01-31' } | Should -Not -Throw
        }

        It 'Should validate date format for From parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -From 'invalid-date' } | Should -Throw
        }

        It 'Should validate date format for To parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -To 'invalid-date' } | Should -Throw
        }

        It 'Should include from in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'from=2024-01-01'
                return $script:MockRecordingList
            }

            Get-ZoomAccountRecordings -AccountId 'me' -From '2024-01-01'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Trash parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept Trash parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -Trash $true } | Should -Not -Throw
        }

        It 'Should accept TrashType parameter' {
            { Get-ZoomAccountRecordings -AccountId 'me' -Trash $true -TrashType 'meeting_recordings' } | Should -Not -Throw
        }

        It 'Should validate TrashType values' {
            { Get-ZoomAccountRecordings -AccountId 'me' -Trash $true -TrashType 'invalid' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomAccountRecordings -AccountId 'me' -ErrorAction Stop } | Should -Throw
        }
    }
}
