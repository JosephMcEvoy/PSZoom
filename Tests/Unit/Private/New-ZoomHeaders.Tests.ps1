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
                # Check if it's a dictionary-like object with string keys
                $headers.GetType().Name | Should -Match 'Dictionary'
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
        It 'Should have Token as mandatory parameter' {
            InModuleScope PSZoom {
                $cmd = Get-Command New-ZoomHeaders
                $tokenParam = $cmd.Parameters['Token']
                $tokenParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                    ForEach-Object { $_.Mandatory } | Should -Contain $true
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
