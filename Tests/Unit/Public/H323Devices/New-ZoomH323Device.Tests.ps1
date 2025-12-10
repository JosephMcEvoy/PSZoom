BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomH323Device' {
    Context 'When creating an H.323/SIP device' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'newdevice123'; name = 'Conference Room' }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomH323Device -Name 'Conference Room' -Protocol 'H.323' -Ip '192.168.1.100'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/h323/devices'
            }
        }

        It 'Should use POST method' {
            New-ZoomH323Device -Name 'Conference Room' -Protocol 'H.323' -Ip '192.168.1.100'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomH323Device -Name 'Conference Room' -Protocol 'H.323' -Ip '192.168.1.100'
            $result.id | Should -Be 'newdevice123'
        }

        It 'Should validate Protocol parameter' {
            { New-ZoomH323Device -Name 'Test' -Protocol 'Invalid' -Ip '192.168.1.100' } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ Name = 'Test'; Protocol = 'SIP'; Ip = '10.0.0.1' } | New-ZoomH323Device
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
