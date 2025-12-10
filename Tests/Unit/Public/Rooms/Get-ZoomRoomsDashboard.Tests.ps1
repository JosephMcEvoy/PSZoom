BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomRoomsDashboard' {
    Context 'When retrieving Zoom Rooms dashboard data' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_number = 1
                    page_size = 30
                    total_records = 2
                    zoom_rooms = @(
                        @{
                            id = 'iA7Lh0BrR7OFnb3SfcWimQ'
                            room_name = 'My Zoom Room1'
                            calendar_name = 'MyZoom.Room1'
                            email = 'MyZoom.Room1@domain.com'
                            account_type = 'Office 365'
                            status = 'Available'
                            device_ip = 'Computer : 192.168.0.1; Controller : 192.168.0.2'
                            camera = 'Logitech MeetUp'
                            microphone = 'Logitech MeetUp Speakerphone'
                            speaker = 'Logitech MeetUp Speakerphone'
                            last_start_time = '2020-08-20T04:31:23Z'
                            issues = @()
                            health = 'noissue'
                            location = 'Ground Floor'
                        }
                        @{
                            id = 'yiEmdlgwTpK0DyQBg97GKA'
                            room_name = 'My Zoom Room2'
                            calendar_name = 'MyZoom.Room2'
                            email = 'MyZoom.Room2@domain.com'
                            account_type = 'Office 365'
                            status = 'Offline'
                            device_ip = 'Computer : 192.168.0.3; Controller : 192.168.0.4'
                            camera = 'BCC950 ConferenceCam'
                            microphone = 'BCC950 ConferenceCam'
                            speaker = 'BCC950 ConferenceCam'
                            last_start_time = '2020-05-26T14:55:54Z'
                            issues = @('Zoom room is offline')
                            health = 'critical'
                            location = 'Ground Floor'
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomRoomsDashboard

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/metrics/zoomrooms*'
            }
        }

        It 'Should not require any parameters' {
            { Get-ZoomRoomsDashboard } | Should -Not -Throw
        }

        It 'Should use default page size of 30' {
            Get-ZoomRoomsDashboard

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomRoomsDashboard -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should accept page_size alias' {
            Get-ZoomRoomsDashboard -page_size 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should include NextPageToken in query when provided' {
            Get-ZoomRoomsDashboard -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should accept next_page_token alias' {
            Get-ZoomRoomsDashboard -next_page_token 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomRoomsDashboard

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return only zoom_rooms array by default' {
            $result = Get-ZoomRoomsDashboard

            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].room_name | Should -Be 'My Zoom Room1'
            $result[0].status | Should -Be 'Available'
            $result[0].health | Should -Be 'noissue'
        }

        It 'Should return full response when Full switch is used' {
            $result = Get-ZoomRoomsDashboard -Full

            $result | Should -Not -BeNullOrEmpty
            $result.page_size | Should -Be 30
            $result.total_records | Should -Be 2
            $result.zoom_rooms | Should -HaveCount 2
        }

        It 'Should include room health status' {
            $result = Get-ZoomRoomsDashboard

            $result[0].health | Should -Be 'noissue'
            $result[1].health | Should -Be 'critical'
        }

        It 'Should include room issues array' {
            $result = Get-ZoomRoomsDashboard

            $result[0].issues | Should -HaveCount 0
            $result[1].issues | Should -HaveCount 1
            $result[1].issues[0] | Should -Be 'Zoom room is offline'
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ zoom_rooms = @() }
            }
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomRoomsDashboard -PageSize 0 } | Should -Throw
            { Get-ZoomRoomsDashboard -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomRoomsDashboard -PageSize 150 } | Should -Not -Throw
        }

        It 'Should accept pipeline input for PageSize by property name' {
            [PSCustomObject]@{ PageSize = 100 } | Get-ZoomRoomsDashboard

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }
    }

}
