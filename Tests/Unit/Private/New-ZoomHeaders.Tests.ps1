BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'New-ZoomHeaders' {
    BeforeAll {
        # Create a test token
        $TestToken = ConvertTo-SecureString 'test-bearer-token-12345' -AsPlainText -Force
    }

    Context 'When generating headers with valid token' {
        It 'Should return a dictionary object' {
            $headers = New-ZoomHeaders -Token $TestToken
            $headers | Should -BeOfType [System.Collections.Generic.Dictionary[String, String]]
        }

        It 'Should contain content-type header' {
            $headers = New-ZoomHeaders -Token $TestToken
            $headers['content-type'] | Should -Be 'application/json'
        }

        It 'Should contain authorization header with bearer prefix' {
            $headers = New-ZoomHeaders -Token $TestToken
            $headers['authorization'] | Should -BeLike 'bearer *'
        }

        It 'Should include the token value in authorization header' {
            $headers = New-ZoomHeaders -Token $TestToken
            $headers['authorization'] | Should -Be 'bearer test-bearer-token-12345'
        }

        It 'Should have exactly 2 headers' {
            $headers = New-ZoomHeaders -Token $TestToken
            $headers.Count | Should -Be 2
        }
    }

    Context 'Parameter validation' {
        It 'Should require Token parameter' {
            { New-ZoomHeaders } | Should -Throw
        }

        It 'Should accept SecureString type for Token' {
            $secureToken = ConvertTo-SecureString 'secure-token' -AsPlainText -Force
            { New-ZoomHeaders -Token $secureToken } | Should -Not -Throw
        }
    }
}
