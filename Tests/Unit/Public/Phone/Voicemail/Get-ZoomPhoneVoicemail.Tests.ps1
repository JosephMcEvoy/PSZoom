BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneVoicemail' {
    Context 'When retrieving voicemail details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'vm123'
                    caller = '+12345678901'
                    callee = '+19876543210'
                    duration = 60
                    status = 'unread'
                    download_url = 'https://example.com/voicemail.mp3'
                }
            }
        }

        It 'Should return voicemail details' {
            $result = Get-ZoomPhoneVoicemail -VoicemailId 'vm123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return correct voicemail ID' {
            $result = Get-ZoomPhoneVoicemail -VoicemailId 'vm123'
            $result.id | Should -Be 'vm123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.AbsoluteUri | Should -Match 'https://api.zoom.us/v2/phone/voicemails/vm123'
                return @{ id = 'vm123' }
            }

            Get-ZoomPhoneVoicemail -VoicemailId 'vm123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'vm123' }
            }

            Get-ZoomPhoneVoicemail -VoicemailId 'vm123'
        }
    }

    Context 'When processing multiple voicemails' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $id = $Uri.AbsolutePath -replace '.*/voicemails/', ''
                return @{ id = $id }
            }
        }

        It 'Should process multiple voicemail IDs' {
            $result = Get-ZoomPhoneVoicemail -VoicemailId 'vm123', 'vm456'
            $result.Count | Should -Be 2
        }

        It 'Should call API for each voicemail ID' {
            Get-ZoomPhoneVoicemail -VoicemailId 'vm1', 'vm2', 'vm3'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should return correct IDs for each voicemail' {
            $result = Get-ZoomPhoneVoicemail -VoicemailId 'vm123', 'vm456'
            $result[0].id | Should -Be 'vm123'
            $result[1].id | Should -Be 'vm456'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'vm123' }
            }
        }

        It 'Should accept VoicemailId from pipeline' {
            { 'vm123' | Get-ZoomPhoneVoicemail } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $vmObject = [PSCustomObject]@{ id = 'vm123' }
            { $vmObject | Get-ZoomPhoneVoicemail } | Should -Not -Throw
        }

        It 'Should accept object with voicemail_id property from pipeline' {
            $vmObject = [PSCustomObject]@{ voicemail_id = 'vm123' }
            { $vmObject | Get-ZoomPhoneVoicemail } | Should -Not -Throw
        }

        It 'Should process multiple objects from pipeline' {
            $voicemails = @(
                [PSCustomObject]@{ id = 'vm123' }
                [PSCustomObject]@{ id = 'vm456' }
            )
            $result = $voicemails | Get-ZoomPhoneVoicemail
            $result.Count | Should -Be 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'vm123' }
            }
        }

        It 'Should accept id alias for VoicemailId' {
            { Get-ZoomPhoneVoicemail -id 'vm123' } | Should -Not -Throw
        }

        It 'Should accept voicemail_id alias for VoicemailId' {
            { Get-ZoomPhoneVoicemail -voicemail_id 'vm123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Voicemail not found')
            }

            { Get-ZoomPhoneVoicemail -VoicemailId 'invalid-vm' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Get-ZoomPhoneVoicemail -VoicemailId 'vm123' -ErrorAction Stop } | Should -Throw
        }
    }
}
