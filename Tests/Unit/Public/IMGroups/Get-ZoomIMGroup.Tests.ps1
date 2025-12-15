BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomIMGroup' {
    Context 'When getting a specific IM group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'abc123'; name = 'Engineering' }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomIMGroup -GroupId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/im/groups/abc123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomIMGroup -GroupId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response object' {
            $result = Get-ZoomIMGroup -GroupId 'abc123'
            $result.name | Should -Be 'Engineering'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ GroupId = 'abc123' } | Get-ZoomIMGroup
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias' {
            [PSCustomObject]@{ id = 'abc123' } | Get-ZoomIMGroup
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
