BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'ConvertTo-LoginTypeCode' {
    Context 'OAuth provider conversions' {
        It 'Should convert Facebook to 0' {
            ConvertTo-LoginTypeCode -Code 'Facebook' | Should -Be '0'
        }

        It 'Should convert FacebookOAuth to 0' {
            ConvertTo-LoginTypeCode -Code 'FacebookOAuth' | Should -Be '0'
        }

        It 'Should convert Google to 1' {
            ConvertTo-LoginTypeCode -Code 'Google' | Should -Be '1'
        }

        It 'Should convert GoogleAuth to 1' {
            ConvertTo-LoginTypeCode -Code 'GoogleAuth' | Should -Be '1'
        }

        It 'Should convert Apple to 24' {
            ConvertTo-LoginTypeCode -Code 'Apple' | Should -Be '24'
        }

        It 'Should convert AppleOAuth to 24' {
            ConvertTo-LoginTypeCode -Code 'AppleOAuth' | Should -Be '24'
        }

        It 'Should convert Microsoft to 27' {
            ConvertTo-LoginTypeCode -Code 'Microsoft' | Should -Be '27'
        }

        It 'Should convert MicrosoftOauth to 27' {
            ConvertTo-LoginTypeCode -Code 'MicrosoftOauth' | Should -Be '27'
        }
    }

    Context 'Special login type conversions' {
        It 'Should convert MobileDevice to 97' {
            ConvertTo-LoginTypeCode -Code 'MobileDevice' | Should -Be '97'
        }

        It 'Should convert RingCentral to 98' {
            ConvertTo-LoginTypeCode -Code 'RingCentral' | Should -Be '98'
        }

        It 'Should convert RingCentralOAuth to 98' {
            ConvertTo-LoginTypeCode -Code 'RingCentralOAuth' | Should -Be '98'
        }

        It 'Should convert APIuser to 99' {
            ConvertTo-LoginTypeCode -Code 'APIuser' | Should -Be '99'
        }

        It 'Should convert ZoomWorkemail to 100' {
            ConvertTo-LoginTypeCode -Code 'ZoomWorkemail' | Should -Be '100'
        }

        It 'Should convert SSO to 101' {
            ConvertTo-LoginTypeCode -Code 'SSO' | Should -Be '101'
        }
    }

    Context 'Regional login type conversions' {
        It 'Should convert PhoneNumber to 11' {
            ConvertTo-LoginTypeCode -Code 'PhoneNumber' | Should -Be '11'
        }

        It 'Should convert WeChat to 21' {
            ConvertTo-LoginTypeCode -Code 'WeChat' | Should -Be '21'
        }

        It 'Should convert Alipay to 23' {
            ConvertTo-LoginTypeCode -Code 'Alipay' | Should -Be '23'
        }
    }

    Context 'Default behavior' {
        It 'Should return original code if not recognized' {
            ConvertTo-LoginTypeCode -Code 'UnknownType' | Should -Be 'UnknownType'
        }

        It 'Should return numeric codes as-is' {
            ConvertTo-LoginTypeCode -Code '99' | Should -Be '99'
        }
    }

    Context 'Parameter validation' {
        It 'Should require Code parameter' {
            { ConvertTo-LoginTypeCode } | Should -Throw
        }
    }
}
