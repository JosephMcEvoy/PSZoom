BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomAccountPlans' {
    Context 'When getting account plans' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    plan_base = @{ type = 'pro'; hosts = 10 }
                    plan_zoom_rooms = @{ type = 'zoom_rooms'; hosts = 5 }
                    plan_webinar = @(@{ type = 'webinar_500'; hosts = 2 })
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomAccountPlans -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/accounts/abc123/plans'
            }
        }

        It 'Should use GET method' {
            Get-ZoomAccountPlans -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response object with plan details' {
            $result = Get-ZoomAccountPlans -AccountId 'abc123'
            $result.plan_base.type | Should -Be 'pro'
            $result.plan_base.hosts | Should -Be 10
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ plan_base = @{} } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123' } | Get-ZoomAccountPlans
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias' {
            [PSCustomObject]@{ id = 'abc123' } | Get-ZoomAccountPlans
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
