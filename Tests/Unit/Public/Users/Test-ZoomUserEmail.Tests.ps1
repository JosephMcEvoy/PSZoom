BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Test-ZoomUserEmail' {
    Context 'When checking email availability' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed_email = $false }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Test-ZoomUserEmail -Email 'newuser@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/users/email*'
            }
        }

        It 'Should include email in query string' {
            Test-ZoomUserEmail -Email 'newuser@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*email=newuser*'
            }
        }

        It 'Should use GET method' {
            Test-ZoomUserEmail -Email 'newuser@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return existed_email property' {
            $result = Test-ZoomUserEmail -Email 'newuser@company.com'
            $result.existed_email | Should -Be $false
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ existed_email = $false } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ Email = 'test@company.com' } | Test-ZoomUserEmail
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
