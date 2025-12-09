BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'New-ZoomHeaders' {
    Context 'When generating headers with valid token' {
        It 'Should return a dictionary object' {
            InModuleScope PSZoom {
                $TestToken = ConvertTo-SecureString 'test-bearer-token-12345' -AsPlainText -Force
                $headers = New-ZoomHeaders -Token $TestToken
                $headers | Should -BeOfType [System.Collections.Generic.Dictionary[String, String]]
            }
        }

        It 'Should contain content-type header' {
            InModuleScope PSZoom {
                $TestToken = ConvertTo-SecureString 'test-bearer-token-12345' -AsPlainText -Force
                $headers = New-ZoomHeaders -Token $TestToken
                $headers['content-type'] | Should -Be 'application/json'
            }
        }

        It 'Should contain authorization header with bearer prefix' {
            InModuleScope PSZoom {
                $TestToken = ConvertTo-SecureString 'test-bearer-token-12345' -AsPlainText -Force
                $headers = New-ZoomHeaders -Token $TestToken
                $headers['authorization'] | Should -BeLike 'bearer *'
            }
        }

        It 'Should include the token value in authorization header' {
            InModuleScope PSZoom {
                $TestToken = ConvertTo-SecureString 'test-bearer-token-12345' -AsPlainText -Force
                $headers = New-ZoomHeaders -Token $TestToken
                $headers['authorization'] | Should -Be 'bearer test-bearer-token-12345'
            }
        }

        It 'Should have exactly 2 headers' {
            InModuleScope PSZoom {
                $TestToken = ConvertTo-SecureString 'test-bearer-token-12345' -AsPlainText -Force
                $headers = New-ZoomHeaders -Token $TestToken
                $headers.Count | Should -Be 2
            }
        }
    }

    Context 'Parameter validation' {
        It 'Should require Token parameter' {
            InModuleScope PSZoom {
                { New-ZoomHeaders } | Should -Throw
            }
        }

        It 'Should accept SecureString type for Token' {
            InModuleScope PSZoom {
                $secureToken = ConvertTo-SecureString 'secure-token' -AsPlainText -Force
                { New-ZoomHeaders -Token $secureToken } | Should -Not -Throw
            }
        }
    }
}
