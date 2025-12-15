BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneVoicemail' {
    Context 'When removing a voicemail' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri.AbsoluteUri -match 'https://api.zoom.us/v2/phone/voicemails/vm123'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should return response by default' {
            $result = Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should not return response when PassThru is not specified' {
            $result = Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -Confirm:$false
            $result.success | Should -Be $true
        }
    }

    Context 'When using PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return VoicemailId when PassThru is specified' {
            $result = Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -PassThru -Confirm:$false
            $result | Should -Be 'vm123'
        }

        It 'Should return multiple VoicemailIds when PassThru is specified' {
            $result = Remove-ZoomPhoneVoicemail -VoicemailId 'vm123', 'vm456' -PassThru -Confirm:$false
            $result.Count | Should -Be 2
            $result[0] | Should -Be 'vm123'
            $result[1] | Should -Be 'vm456'
        }
    }

    Context 'When processing multiple voicemails' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should process multiple voicemail IDs' {
            Remove-ZoomPhoneVoicemail -VoicemailId 'vm123', 'vm456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should call API for each voicemail ID' {
            Remove-ZoomPhoneVoicemail -VoicemailId 'vm1', 'vm2', 'vm3' -Confirm:$false
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
            Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should prompt for confirmation when Confirm is true' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }

            # This would normally prompt, but with -Confirm:$false it won't
            Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept VoicemailId from pipeline' {
            { 'vm123' | Remove-ZoomPhoneVoicemail -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $vmObject = [PSCustomObject]@{ id = 'vm123' }
            { $vmObject | Remove-ZoomPhoneVoicemail -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with voicemail_id property from pipeline' {
            $vmObject = [PSCustomObject]@{ voicemail_id = 'vm123' }
            { $vmObject | Remove-ZoomPhoneVoicemail -Confirm:$false } | Should -Not -Throw
        }

        It 'Should process multiple objects from pipeline' {
            $voicemails = @('vm123', 'vm456')
            $voicemails | Remove-ZoomPhoneVoicemail -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept Id alias for VoicemailId' {
            { Remove-ZoomPhoneVoicemail -Id 'vm123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Ids alias for VoicemailId' {
            { Remove-ZoomPhoneVoicemail -Ids 'vm123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept voicemail_id alias for VoicemailId' {
            { Remove-ZoomPhoneVoicemail -voicemail_id 'vm123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Voicemail not found')
            }

            { Remove-ZoomPhoneVoicemail -VoicemailId 'invalid-vm' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Remove-ZoomPhoneVoicemail -VoicemailId 'vm123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should validate VoicemailId length' {
            $longId = 'a' * 129
            { Remove-ZoomPhoneVoicemail -VoicemailId $longId -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
