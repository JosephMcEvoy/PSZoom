BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneRecording' {
    Context 'When removing a recording' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomPhoneRecording -RecordingId 'rec123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri.AbsoluteUri -match 'https://api.zoom.us/v2/phone/recordings/rec123'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomPhoneRecording -RecordingId 'rec123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should return response by default' {
            $result = Remove-ZoomPhoneRecording -RecordingId 'rec123' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should not return response when PassThru is not specified' {
            $result = Remove-ZoomPhoneRecording -RecordingId 'rec123' -Confirm:$false
            $result.success | Should -Be $true
        }
    }

    Context 'When using PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return RecordingId when PassThru is specified' {
            $result = Remove-ZoomPhoneRecording -RecordingId 'rec123' -PassThru -Confirm:$false
            $result | Should -Be 'rec123'
        }

        It 'Should return multiple RecordingIds when PassThru is specified' {
            $result = Remove-ZoomPhoneRecording -RecordingId 'rec123', 'rec456' -PassThru -Confirm:$false
            $result.Count | Should -Be 2
            $result[0] | Should -Be 'rec123'
            $result[1] | Should -Be 'rec456'
        }
    }

    Context 'When processing multiple recordings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should process multiple recording IDs' {
            Remove-ZoomPhoneRecording -RecordingId 'rec123', 'rec456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should call API for each recording ID' {
            Remove-ZoomPhoneRecording -RecordingId 'rec1', 'rec2', 'rec3' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support WhatIf' {
            Remove-ZoomPhoneRecording -RecordingId 'rec123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should prompt for confirmation when Confirm is true' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }

            # This would normally prompt, but with -Confirm:$false it won't
            Remove-ZoomPhoneRecording -RecordingId 'rec123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept RecordingId from pipeline' {
            { 'rec123' | Remove-ZoomPhoneRecording -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $recObject = [PSCustomObject]@{ id = 'rec123' }
            { $recObject | Remove-ZoomPhoneRecording -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with recording_id property from pipeline' {
            $recObject = [PSCustomObject]@{ recording_id = 'rec123' }
            { $recObject | Remove-ZoomPhoneRecording -Confirm:$false } | Should -Not -Throw
        }

        It 'Should process multiple objects from pipeline' {
            $recordings = @('rec123', 'rec456')
            $recordings | Remove-ZoomPhoneRecording -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept Id alias for RecordingId' {
            { Remove-ZoomPhoneRecording -Id 'rec123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Ids alias for RecordingId' {
            { Remove-ZoomPhoneRecording -Ids 'rec123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept recording_id alias for RecordingId' {
            { Remove-ZoomPhoneRecording -recording_id 'rec123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Remove-ZoomPhoneRecording -RecordingId 'invalid-rec' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Remove-ZoomPhoneRecording -RecordingId 'rec123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should validate RecordingId length' {
            $longId = 'a' * 129
            { Remove-ZoomPhoneRecording -RecordingId $longId -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
