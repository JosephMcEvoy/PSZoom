BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomAccountPlan' {
    Context 'When subscribing to a plan' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    plan_base = @{ type = 'pro'; hosts = 10 }
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomAccountPlan -AccountId 'abc123' -PlanBase @{ type = 'pro'; hosts = 10 }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/accounts/abc123/plans'
            }
        }

        It 'Should use POST method' {
            New-ZoomAccountPlan -AccountId 'abc123' -PlanBase @{ type = 'pro'; hosts = 10 }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomAccountPlan -AccountId 'abc123' -PlanBase @{ type = 'pro'; hosts = 10 }
            $result.plan_base.type | Should -Be 'pro'
        }

        It 'Should accept optional addon plans' {
            { New-ZoomAccountPlan -AccountId 'abc123' -PlanBase @{ type = 'pro'; hosts = 10 } -PlanWebinar @(@{ type = 'webinar_500'; hosts = 2 }) } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123'; PlanBase = @{ type = 'pro'; hosts = 10 } } | New-ZoomAccountPlan
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
