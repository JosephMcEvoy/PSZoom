BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomH323Devices' {
    Context 'When listing H.323/SIP devices' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    devices = @(
                        @{ id = 'device1'; name = 'Conference Room A' }
                        @{ id = 'device2'; name = 'Conference Room B' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomH323Devices
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/h323/devices*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomH323Devices
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response with devices' {
            $result = Get-ZoomH323Devices
            $result.devices | Should -HaveCount 2
        }

        It 'Should accept PageSize parameter' {
            Get-ZoomH323Devices -PageSize 100
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=100*'
            }
        }
    }
}
