BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSMSSession' {
    Context 'When retrieving a specific SMS session' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'session123'
                    messages = @()
                    participants = @('+14155551234', '+14155555678')
                }
            }
        }

        It 'Should return an SMS session' {
            $result = Get-ZoomPhoneSMSSession -SessionId 'session123'
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'session123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/sms/sessions/session123'
                return @{ id = 'session123' }
            }

            Get-ZoomPhoneSMSSession -SessionId 'session123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'session123' }
            }

            Get-ZoomPhoneSMSSession -SessionId 'session123'
        }
    }

    Context 'When retrieving multiple SMS sessions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                if ($Uri -match 'session123') {
                    return @{ id = 'session123'; messages = @() }
                } elseif ($Uri -match 'session456') {
                    return @{ id = 'session456'; messages = @() }
                }
            }
        }

        It 'Should handle multiple SessionIds' {
            $result = Get-ZoomPhoneSMSSession -SessionId 'session123', 'session456'
            $result.Count | Should -Be 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'session123' }
            }
        }

        It 'Should accept SessionId from pipeline' {
            { 'session123' | Get-ZoomPhoneSMSSession } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $sessionObject = [PSCustomObject]@{ id = 'session123' }
            { $sessionObject | Get-ZoomPhoneSMSSession } | Should -Not -Throw
        }

        It 'Should accept object with session_id property from pipeline' {
            $sessionObject = [PSCustomObject]@{ session_id = 'session123' }
            { $sessionObject | Get-ZoomPhoneSMSSession } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'session123' }
            }
        }

        It 'Should accept session_id alias' {
            { Get-ZoomPhoneSMSSession -session_id 'session123' } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Get-ZoomPhoneSMSSession -id 'session123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require SessionId parameter' {
            { Get-ZoomPhoneSMSSession -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('SMS session not found')
            }

            { Get-ZoomPhoneSMSSession -SessionId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
