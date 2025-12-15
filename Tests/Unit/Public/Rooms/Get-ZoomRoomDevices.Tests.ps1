BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomRoomDevices' {
    Context 'When retrieving Zoom Room devices' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    devices = @(
                        @{
                            id = '3923ZF49-E16E-48C5-8E3D-247406D7F059'
                            room_name = 'My Zoom Room1'
                            device_type = 'Controller'
                            app_version = '5.1.2 (112.0821)'
                            device_system = 'iPad 13.6.1'
                            status = 'Offline'
                        }
                        @{
                            id = 'o-rZ1K-hTeCpaL7mJN9Ngg-0'
                            room_name = 'My Zoom Room1'
                            device_type = 'Zoom Rooms Computer'
                            app_version = '5.1.1 (1624.0806)'
                            app_target_version = '5.1.2 (1697.0821)'
                            device_system = 'Win 10'
                            status = 'Offline'
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomRoomDevices -RoomID 'room123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/devices'
            }
        }

        It 'Should require RoomID parameter' {
            { Get-ZoomRoomDevices } | Should -Throw
        }

        It 'Should use GET method' {
            Get-ZoomRoomDevices -RoomID 'room123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return only the devices array' {
            $result = Get-ZoomRoomDevices -RoomID 'room123'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].device_type | Should -Be 'Controller'
            $result[1].device_type | Should -Be 'Zoom Rooms Computer'
        }

        It 'Should return device details with all expected properties' {
            $result = Get-ZoomRoomDevices -RoomID 'room123'

            $result[0].id | Should -Be '3923ZF49-E16E-48C5-8E3D-247406D7F059'
            $result[0].room_name | Should -Be 'My Zoom Room1'
            $result[0].device_type | Should -Be 'Controller'
            $result[0].app_version | Should -Be '5.1.2 (112.0821)'
            $result[0].device_system | Should -Be 'iPad 13.6.1'
            $result[0].status | Should -Be 'Offline'
        }

        It 'Should handle device with app_target_version' {
            $result = Get-ZoomRoomDevices -RoomID 'room123'

            $result[1].app_target_version | Should -Be '5.1.2 (1697.0821)'
        }
    }


    Context 'When room has no devices' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    devices = @()
                }
            }
        }

        It 'Should return empty array when no devices exist' {
            $result = Get-ZoomRoomDevices -RoomID 'room123'

            $result | Should -BeNullOrEmpty
        }
    }

    Context 'When validating API endpoint construction' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ devices = @() }
            }
        }

        It 'Should construct correct URI with room ID' {
            Get-ZoomRoomDevices -RoomID 'V5-1Nno-Sf-gtHn_k-GaRw'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/V5-1Nno-Sf-gtHn_k-GaRw/devices'
            }
        }

        It 'Should accept RoomID as string parameter' {
            { Get-ZoomRoomDevices -RoomID 'room123' } | Should -Not -Throw
        }
    }
}
