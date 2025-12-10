BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Test-ZoomUserVanityName' {
    Context 'When checking vanity name availability' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed = $false }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Test-ZoomUserVanityName -VanityName 'mycompany'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/users/vanity_name*'
            }
        }

        It 'Should include vanity_name in query string' {
            Test-ZoomUserVanityName -VanityName 'mycompany'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*vanity_name=mycompany*'
            }
        }

        It 'Should use GET method' {
            Test-ZoomUserVanityName -VanityName 'mycompany'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return existed property' {
            $result = Test-ZoomUserVanityName -VanityName 'mycompany'
            $result.existed | Should -Be $false
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ existed = $false } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ VanityName = 'testname' } | Test-ZoomUserVanityName
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
