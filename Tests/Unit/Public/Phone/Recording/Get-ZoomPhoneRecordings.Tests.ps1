BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneRecordings' {
    Context 'When retrieving all recordings' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'rec123'
                        caller = '+12345678901'
                        duration = 120
                        file_size = 1024000
                    }
                    @{
                        id = 'rec456'
                        caller = '+15551234567'
                        duration = 300
                        file_size = 2048000
                    }
                )
            }
        }

        It 'Should return recordings' {
            $result = Get-ZoomPhoneRecordings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple recordings' {
            $result = Get-ZoomPhoneRecordings
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/recordings'
                return @()
            }

            Get-ZoomPhoneRecordings
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }
    }

    Context 'When retrieving specific recordings by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'rec123'
                        caller = '+12345678901'
                    }
                )
            }
        }

        It 'Should accept RecordingId parameter' {
            $result = Get-ZoomPhoneRecordings -RecordingId 'rec123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'rec123'
                return @()
            }

            Get-ZoomPhoneRecordings -RecordingId 'rec123'
        }

        It 'Should accept multiple RecordingIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneRecordings -RecordingId 'rec123', 'rec456'
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

            Get-ZoomPhoneRecordings -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneRecordings -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneRecordings -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'rec123' }
                    @{ id = 'rec456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'rec123'; details = 'full' }
                    @{ id = 'rec456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneRecordings -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneRecordings'
                return @()
            }

            Get-ZoomPhoneRecordings -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept RecordingId from pipeline' {
            { 'rec123' | Get-ZoomPhoneRecordings } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $recObject = [PSCustomObject]@{ id = 'rec123' }
            { $recObject | Get-ZoomPhoneRecordings } | Should -Not -Throw
        }

        It 'Should accept object with recording_id property from pipeline' {
            $recObject = [PSCustomObject]@{ recording_id = 'rec123' }
            { $recObject | Get-ZoomPhoneRecordings } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for RecordingId' {
            { Get-ZoomPhoneRecordings -id 'rec123' } | Should -Not -Throw
        }

        It 'Should accept recording_id alias for RecordingId' {
            { Get-ZoomPhoneRecordings -recording_id 'rec123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneRecordings -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneRecordings -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneRecording alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneRecording' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneRecordings'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Get-ZoomPhoneRecordings -RecordingId 'rec123' -ErrorAction Stop } | Should -Throw
        }
    }
}
