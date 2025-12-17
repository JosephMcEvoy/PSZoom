BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state within module scope
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomAccountLockSettings' {
    Context 'When retrieving account lock settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    schedule_meeting = @{
                        host_video = $true
                        participant_video = $true
                        audio_type = $true
                    }
                    in_meeting = @{
                        e2e_encryption = $true
                        chat = $true
                        private_chat = $true
                    }
                    email_notification = @{
                        jbh_reminder = $true
                        cancel_meeting_reminder = $true
                    }
                }
            }
        }

        It 'Should return account lock settings' {
            $result = Get-ZoomAccountLockSettings -AccountId 'abc123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomAccountLockSettings -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/lock_settings*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomAccountLockSettings -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return schedule_meeting settings' {
            $result = Get-ZoomAccountLockSettings -AccountId 'abc123'
            $result.schedule_meeting | Should -Not -BeNullOrEmpty
        }

        It 'Should return in_meeting settings' {
            $result = Get-ZoomAccountLockSettings -AccountId 'abc123'
            $result.in_meeting | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    schedule_meeting = @{ host_video = $true }
                }
            }
        }

        It 'Should accept pipeline input by value' {
            'abc123' | Get-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*abc123*'
            }
        }

        It 'Should accept pipeline input by property name (AccountId)' {
            [PSCustomObject]@{ AccountId = 'xyz789' } | Get-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*xyz789*'
            }
        }

        It 'Should accept pipeline input by property name (account_id)' {
            [PSCustomObject]@{ account_id = 'test456' } | Get-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*test456*'
            }
        }

        It 'Should accept pipeline input by property name (id)' {
            [PSCustomObject]@{ id = 'id999' } | Get-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*id999*'
            }
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should require AccountId parameter' {
            { Get-ZoomAccountLockSettings } | Should -Throw
        }

        It 'Should accept AccountId as string' {
            { Get-ZoomAccountLockSettings -AccountId 'abc123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomAccountLockSettings -AccountId 'abc123' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle 404 not found error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('The remote server returned an error: (404) Not Found.')
            }

            { Get-ZoomAccountLockSettings -AccountId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
