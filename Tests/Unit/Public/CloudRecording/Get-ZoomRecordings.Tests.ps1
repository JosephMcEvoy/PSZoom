BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:MockRecordingList = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/recording-list.json" | ConvertFrom-Json
}

Describe 'Get-ZoomRecordings' {
    Context 'When retrieving user recordings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should return recording list' {
            $result = Get-ZoomRecordings -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return meetings array' {
            $result = Get-ZoomRecordings -UserId 'user@example.com'
            $result.meetings | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct user recordings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/users/.*/recordings'
                return $script:MockRecordingList
            }

            Get-ZoomRecordings -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockRecordingList
            }

            Get-ZoomRecordings -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomRecordings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should process multiple UserIds' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }

            @('user1@example.com', 'user2@example.com') | Get-ZoomRecordings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -PageSize 50 } | Should -Not -Throw
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomRecordings -UserId 'user@example.com' -PageSize 0 } | Should -Throw
            { Get-ZoomRecordings -UserId 'user@example.com' -PageSize 301 } | Should -Throw
        }

        It 'Should accept NextPageToken parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -NextPageToken 'abc123' } | Should -Not -Throw
        }
    }

    Context 'Date range parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept From parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -From '2024-01-01' } | Should -Not -Throw
        }

        It 'Should accept To parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -To '2024-01-31' } | Should -Not -Throw
        }

        It 'Should validate date format' {
            { Get-ZoomRecordings -UserId 'user@example.com' -From 'invalid' } | Should -Throw
        }
    }

    Context 'Trash parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept Trash parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -Trash $true } | Should -Not -Throw
        }

        It 'Should accept TrashType parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -TrashType 'meeting_recordings' } | Should -Not -Throw
        }

        It 'Should validate TrashType values' {
            { Get-ZoomRecordings -UserId 'user@example.com' -TrashType 'invalid' } | Should -Throw
        }
    }

    Context 'MC parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingList
            }
        }

        It 'Should accept MC parameter' {
            { Get-ZoomRecordings -UserId 'user@example.com' -MC $true } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require UserId parameter' {
            { Get-ZoomRecordings } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomRecordings -UserId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
