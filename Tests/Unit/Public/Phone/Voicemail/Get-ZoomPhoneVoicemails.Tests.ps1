BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneVoicemails' {
    Context 'When retrieving all voicemails' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'vm123'
                        caller = '+12345678901'
                        duration = 60
                        status = 'unread'
                    }
                    @{
                        id = 'vm456'
                        caller = '+15551234567'
                        duration = 90
                        status = 'read'
                    }
                )
            }
        }

        It 'Should return voicemails' {
            $result = Get-ZoomPhoneVoicemails
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple voicemails' {
            $result = Get-ZoomPhoneVoicemails
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/voicemails'
                return @()
            }

            Get-ZoomPhoneVoicemails
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }
    }

    Context 'When retrieving specific voicemails by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'vm123'
                        caller = '+12345678901'
                    }
                )
            }
        }

        It 'Should accept VoicemailId parameter' {
            $result = Get-ZoomPhoneVoicemails -VoicemailId 'vm123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'vm123'
                return @()
            }

            Get-ZoomPhoneVoicemails -VoicemailId 'vm123'
        }

        It 'Should accept multiple VoicemailIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneVoicemails -VoicemailId 'vm123', 'vm456'
        }
    }

    Context 'When using pagination parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept PageSize parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 50
                return @()
            }

            Get-ZoomPhoneVoicemails -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneVoicemails -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneVoicemails -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'vm123' }
                    @{ id = 'vm456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'vm123'; details = 'full' }
                    @{ id = 'vm456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneVoicemails -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneVoicemails'
                return @()
            }

            Get-ZoomPhoneVoicemails -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept VoicemailId from pipeline' {
            { 'vm123' | Get-ZoomPhoneVoicemails } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $vmObject = [PSCustomObject]@{ id = 'vm123' }
            { $vmObject | Get-ZoomPhoneVoicemails } | Should -Not -Throw
        }

        It 'Should accept object with voicemail_id property from pipeline' {
            $vmObject = [PSCustomObject]@{ voicemail_id = 'vm123' }
            { $vmObject | Get-ZoomPhoneVoicemails } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for VoicemailId' {
            { Get-ZoomPhoneVoicemails -id 'vm123' } | Should -Not -Throw
        }

        It 'Should accept voicemail_id alias for VoicemailId' {
            { Get-ZoomPhoneVoicemails -voicemail_id 'vm123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneVoicemails -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneVoicemails -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneVoicemail alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneVoicemail' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneVoicemails'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Voicemail not found')
            }

            { Get-ZoomPhoneVoicemails -VoicemailId 'vm123' -ErrorAction Stop } | Should -Throw
        }
    }
}
