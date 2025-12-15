BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'ConvertTo-StringWithCommas' {
    Context 'When converting arrays to comma-separated strings' {
        It 'Should convert numeric array to comma-separated string' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @(1, 2, 3, 4)
                $result | Should -Be '1,2,3,4'
            }
        }

        It 'Should convert string array to comma-separated string' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @('a', 'b', 'c')
                $result | Should -Be 'a,b,c'
            }
        }

        It 'Should handle single element array' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @('single')
                $result | Should -Be 'single'
            }
        }

        It 'Should handle two element array' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @('first', 'second')
                $result | Should -Be 'first,second'
            }
        }

        It 'Should handle mixed type array' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @(1, 'two', 3)
                $result | Should -Be '1,two,3'
            }
        }
    }

    Context 'Edge cases' {
        It 'Should handle array with spaces in values' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @('hello world', 'foo bar')
                $result | Should -Be 'hello world,foo bar'
            }
        }

        It 'Should handle numeric strings' {
            InModuleScope PSZoom {
                $result = ConvertTo-StringWithCommas -Array @('123', '456', '789')
                $result | Should -Be '123,456,789'
            }
        }
    }
}
