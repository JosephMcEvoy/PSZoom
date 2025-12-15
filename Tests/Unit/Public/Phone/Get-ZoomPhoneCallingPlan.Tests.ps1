BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneCallingPlan' {
    Context 'When retrieving calling plans' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    calling_plans = @(
                        @{
                            id = 1
                            name = 'US & Canada Metered'
                            type = 1
                        }
                        @{
                            id = 2
                            name = 'US & Canada Unlimited'
                            type = 2
                        }
                    )
                }
            }
        }

        It 'Should return calling plans' {
            $result = Get-ZoomPhoneCallingPlan
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple calling plans' {
            $result = Get-ZoomPhoneCallingPlan
            $result.Count | Should -BeGreaterThan 0
        }

        It 'Should expand calling_plans property' {
            $result = Get-ZoomPhoneCallingPlan
            $result[0].id | Should -Be 1
            $result[0].name | Should -Be 'US & Canada Metered'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct calling plans endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/phone/calling_plans'
                return @{ calling_plans = @() }
            }

            Get-ZoomPhoneCallingPlan
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ calling_plans = @() }
            }

            Get-ZoomPhoneCallingPlan
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should construct proper URI with ZoomURI variable' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'https://api.zoom.us/v2/phone/calling_plans'
                return @{ calling_plans = @() }
            }

            Get-ZoomPhoneCallingPlan
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneCallingPlans alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneCallingPlans' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneCallingPlan'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API request failed')
            }

            { Get-ZoomPhoneCallingPlan -ErrorAction Stop } | Should -Throw
        }
    }
}
