BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'zoom.us'
    $script:MockResponse = Get-Content -Path $PSScriptRoot/../../../Fixtures/MockResponses/p-h-o-n-e-a-c-c-o-u-n-t-s-e-t-t-i-n-g-s-get.json -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomPhoneAccountSettings' {
    BeforeEach {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns phone account settings data' {
            $result = Get-ZoomPhoneAccountSettings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Exactly -Times 1
        }

        It 'Uses GET method' {
            Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct base URI without parameters' {
            Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*://api.zoom.us/v2/phone/account_settings*'
            }
        }

        It 'Includes setting_types query parameter when SettingTypes is specified' {
            Get-ZoomPhoneAccountSettings -SettingTypes 'voicemail,sms'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*setting_types=voicemail*sms*'
            }
        }

        It 'Constructs correct URI with single setting type' {
            Get-ZoomPhoneAccountSettings -SettingTypes 'voicemail'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*setting_types=voicemail*'
            }
        }

        It 'Constructs correct URI with multiple setting types' {
            Get-ZoomPhoneAccountSettings -SettingTypes 'auto_call_recording,ad_hoc_call_recording,e2e_encryption'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*setting_types=auto_call_recording*ad_hoc_call_recording*e2e_encryption*'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Has SettingTypes parameter with correct alias setting_types' {
            $command = Get-Command Get-ZoomPhoneAccountSettings -Module PSZoom
            $command.Parameters['SettingTypes'].Aliases | Should -Contain 'setting_types'
        }

        It 'SettingTypes parameter accepts string type' {
            $command = Get-Command Get-ZoomPhoneAccountSettings -Module PSZoom
            $command.Parameters['SettingTypes'].ParameterType.Name | Should -Be 'String'
        }

        It 'SettingTypes parameter is not mandatory' {
            $command = Get-Command Get-ZoomPhoneAccountSettings -Module PSZoom
            $command.Parameters['SettingTypes'].Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] }).Mandatory | Should -Contain $false
        }

        It 'SettingTypes parameter accepts pipeline input by property name' {
            $command = Get-Command Get-ZoomPhoneAccountSettings -Module PSZoom
            $paramAttr = $command.Parameters['SettingTypes'].Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $paramAttr.ValueFromPipelineByPropertyName | Should -Contain $true
        }

        It 'SettingTypes parameter accepts pipeline input by value' {
            $command = Get-Command Get-ZoomPhoneAccountSettings -Module PSZoom
            $paramAttr = $command.Parameters['SettingTypes'].Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $paramAttr.ValueFromPipeline | Should -Contain $true
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts SettingTypes from pipeline by value' {
            'voicemail' | Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*setting_types=voicemail*'
            }
        }

        It 'Accepts SettingTypes from pipeline by property name' {
            [PSCustomObject]@{ SettingTypes = 'sms,voicemail' } | Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*setting_types=sms*voicemail*'
            }
        }

        It 'Accepts SettingTypes from pipeline using alias setting_types' {
            [PSCustomObject]@{ setting_types = 'e2e_encryption' } | Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*setting_types=e2e_encryption*'
            }
        }

        It 'Processes multiple pipeline inputs' {
            @('voicemail', 'sms') | Get-ZoomPhoneAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Exactly -Times 2
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'API Error' }
            { Get-ZoomPhoneAccountSettings } | Should -Throw
        }

        It 'Handles empty response gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $null }
            $result = Get-ZoomPhoneAccountSettings
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Output Validation' {
        It 'Returns response object directly' {
            $result = Get-ZoomPhoneAccountSettings
            $result | Should -BeOfType [PSCustomObject]
        }
    }
}
