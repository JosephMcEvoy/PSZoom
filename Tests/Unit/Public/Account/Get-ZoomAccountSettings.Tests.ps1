BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state within module scope
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    # Load mock response fixtures
    $script:MockAccountSettings = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/account-settings.json" | ConvertFrom-Json
}

Describe 'Get-ZoomAccountSettings' {
    Context 'When retrieving account settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountSettings
            }
        }

        It 'Should return account settings' {
            $result = Get-ZoomAccountSettings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return schedule_meeting settings' {
            $result = Get-ZoomAccountSettings
            $result.schedule_meeting | Should -Not -BeNullOrEmpty
        }

        It 'Should return in_meeting settings' {
            $result = Get-ZoomAccountSettings
            $result.in_meeting | Should -Not -BeNullOrEmpty
        }

        It 'Should return recording settings' {
            $result = Get-ZoomAccountSettings
            $result.recording | Should -Not -BeNullOrEmpty
        }

        It 'Should return feature settings' {
            $result = Get-ZoomAccountSettings
            $result.feature | Should -Not -BeNullOrEmpty
        }

        It 'Should return correct meeting capacity' {
            $result = Get-ZoomAccountSettings
            $result.feature.meeting_capacity | Should -Be 500
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct settings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/accounts/me/settings'
                return $script:MockAccountSettings
            }

            Get-ZoomAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockAccountSettings
            }

            Get-ZoomAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'No parameters required' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountSettings
            }
        }

        It 'Should work without any parameters' {
            { Get-ZoomAccountSettings } | Should -Not -Throw
        }
    }

    Context 'Return value structure' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountSettings
            }
        }

        It 'Should return object with expected setting categories' {
            $result = Get-ZoomAccountSettings

            $result.schedule_meeting | Should -Not -BeNullOrEmpty
            $result.in_meeting | Should -Not -BeNullOrEmpty
            $result.email_notification | Should -Not -BeNullOrEmpty
            $result.recording | Should -Not -BeNullOrEmpty
            $result.telephony | Should -Not -BeNullOrEmpty
            $result.feature | Should -Not -BeNullOrEmpty
        }

        It 'Should return schedule_meeting with host_video setting' {
            $result = Get-ZoomAccountSettings
            $result.schedule_meeting.host_video | Should -BeTrue
        }

        It 'Should return in_meeting with chat setting' {
            $result = Get-ZoomAccountSettings
            $result.in_meeting.chat | Should -BeTrue
        }

        It 'Should return recording with cloud_recording setting' {
            $result = Get-ZoomAccountSettings
            $result.recording.cloud_recording | Should -BeTrue
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomAccountSettings -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle 401 unauthorized error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('The remote server returned an error: (401) Unauthorized.')
            }

            { Get-ZoomAccountSettings -ErrorAction Stop } | Should -Throw
        }
    }
}
