BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:MockResponsePath = "$PSScriptRoot/../../../Fixtures/MockResponses/phone-account-settings-get.json"
    $script:MockResponse = Get-Content -Path $script:MockResponsePath -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomPhoneAccountSettings' {
    Context 'When retrieving phone account settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockResponse
            }
        }

        It 'Should return phone account settings' {
            $result = Get-ZoomPhoneAccountSettings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return voicemail settings' {
            $result = Get-ZoomPhoneAccountSettings
            $result.voicemail | Should -Not -BeNullOrEmpty
            $result.voicemail.access_members_in_directory | Should -Be $true
        }

        It 'Should return sms settings' {
            $result = Get-ZoomPhoneAccountSettings
            $result.sms | Should -Not -BeNullOrEmpty
            $result.sms.enable | Should -Be $true
        }

        It 'Should return call_park settings' {
            $result = Get-ZoomPhoneAccountSettings
            $result.call_park | Should -Not -BeNullOrEmpty
            $result.call_park.enable | Should -Be $true
        }

        It 'Should return e2e_encryption settings' {
            $result = Get-ZoomPhoneAccountSettings
            $result.e2e_encryption | Should -Not -BeNullOrEmpty
            $result.e2e_encryption.enable | Should -Be $true
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct phone account settings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/phone/account_settings'
                return $script:MockResponse
            }

            Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockResponse
            }

            Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should construct proper URI with ZoomURI variable' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'https://api.zoom.us/v2/phone/account_settings'
                return $script:MockResponse
            }

            Get-ZoomPhoneAccountSettings
        }
    }

    Context 'SettingTypes parameter' {
        It 'Should include setting_types query parameter when specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'setting_types=voicemail'
                return $script:MockResponse
            }

            Get-ZoomPhoneAccountSettings -SettingTypes 'voicemail'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should support multiple setting types as comma-separated string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'setting_types=voicemail%2csms%2ccall_park'
                return $script:MockResponse
            }

            Get-ZoomPhoneAccountSettings -SettingTypes 'voicemail,sms,call_park'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not include setting_types when parameter is not specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Not -Match 'setting_types='
                return $script:MockResponse
            }

            Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should support setting_types alias' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'setting_types=sms'
                return $script:MockResponse
            }

            $params = @{ setting_types = 'sms' }
            Get-ZoomPhoneAccountSettings @params
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockResponse
            }
        }

        It 'Should accept SettingTypes from pipeline by value' {
            $result = 'voicemail' | Get-ZoomPhoneAccountSettings
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept setting_types from pipeline by property name' {
            $inputObject = [PSCustomObject]@{ setting_types = 'sms' }
            $result = $inputObject | Get-ZoomPhoneAccountSettings
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept SettingTypes from pipeline by property name' {
            $inputObject = [PSCustomObject]@{ SettingTypes = 'call_park' }
            $result = $inputObject | Get-ZoomPhoneAccountSettings
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should have SettingTypes parameter with correct attributes' {
            $command = Get-Command Get-ZoomPhoneAccountSettings
            $param = $command.Parameters['SettingTypes']
            $param | Should -Not -BeNullOrEmpty
            $param.ParameterType.Name | Should -Be 'String'
        }

        It 'Should have setting_types as alias for SettingTypes' {
            $command = Get-Command Get-ZoomPhoneAccountSettings
            $param = $command.Parameters['SettingTypes']
            $param.Aliases | Should -Contain 'setting_types'
        }

        It 'Should have SettingTypes at position 0' {
            $command = Get-Command Get-ZoomPhoneAccountSettings
            $param = $command.Parameters['SettingTypes']
            $attributes = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
            $attributes.Position | Should -Be 0
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API request failed')
            }

            { Get-ZoomPhoneAccountSettings -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors with SettingTypes parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid setting type')
            }

            { Get-ZoomPhoneAccountSettings -SettingTypes 'invalid_setting' -ErrorAction Stop } | Should -Throw
        }
    }
}
