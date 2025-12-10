BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneRecording' {
    Context 'When retrieving recording details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'rec123'
                    caller = '+12345678901'
                    callee = '+19876543210'
                    duration = 120
                    file_size = 1024000
                    download_url = 'https://example.com/recording.mp3'
                }
            }
        }

        It 'Should return recording details' {
            $result = Get-ZoomPhoneRecording -RecordingId 'rec123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return correct recording ID' {
            $result = Get-ZoomPhoneRecording -RecordingId 'rec123'
            $result.id | Should -Be 'rec123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.AbsoluteUri | Should -Match 'https://api.zoom.us/v2/phone/recordings/rec123'
                return @{ id = 'rec123' }
            }

            Get-ZoomPhoneRecording -RecordingId 'rec123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'rec123' }
            }

            Get-ZoomPhoneRecording -RecordingId 'rec123'
        }
    }

    Context 'When processing multiple recordings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $id = $Uri.AbsolutePath -replace '.*/recordings/', ''
                return @{ id = $id }
            }
        }

        It 'Should process multiple recording IDs' {
            $result = Get-ZoomPhoneRecording -RecordingId 'rec123', 'rec456'
            $result.Count | Should -Be 2
        }

        It 'Should call API for each recording ID' {
            Get-ZoomPhoneRecording -RecordingId 'rec1', 'rec2', 'rec3'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should return correct IDs for each recording' {
            $result = Get-ZoomPhoneRecording -RecordingId 'rec123', 'rec456'
            $result[0].id | Should -Be 'rec123'
            $result[1].id | Should -Be 'rec456'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'rec123' }
            }
        }

        It 'Should accept RecordingId from pipeline' {
            { 'rec123' | Get-ZoomPhoneRecording } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $recObject = [PSCustomObject]@{ id = 'rec123' }
            { $recObject | Get-ZoomPhoneRecording } | Should -Not -Throw
        }

        It 'Should accept object with recording_id property from pipeline' {
            $recObject = [PSCustomObject]@{ recording_id = 'rec123' }
            { $recObject | Get-ZoomPhoneRecording } | Should -Not -Throw
        }

        It 'Should process multiple objects from pipeline' {
            $recordings = @(
                [PSCustomObject]@{ id = 'rec123' }
                [PSCustomObject]@{ id = 'rec456' }
            )
            $result = $recordings | Get-ZoomPhoneRecording
            $result.Count | Should -Be 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'rec123' }
            }
        }

        It 'Should accept id alias for RecordingId' {
            { Get-ZoomPhoneRecording -id 'rec123' } | Should -Not -Throw
        }

        It 'Should accept recording_id alias for RecordingId' {
            { Get-ZoomPhoneRecording -recording_id 'rec123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Get-ZoomPhoneRecording -RecordingId 'invalid-rec' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Get-ZoomPhoneRecording -RecordingId 'rec123' -ErrorAction Stop } | Should -Throw
        }
    }
}
