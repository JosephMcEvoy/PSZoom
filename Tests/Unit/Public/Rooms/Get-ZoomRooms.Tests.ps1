BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomRooms' {
    Context 'When retrieving Zoom Rooms' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_size = 30
                    next_page_token = ''
                    rooms = @(
                        @{
                            id = 'bo5ZalTCRZ6dsutGR4SF2A'
                            room_id = '8Fudh-eORuCPpWNk5G7tHg'
                            name = 'My Zoom Room1'
                            location_id = '0Dwnr3pfRbFPDVZSulvUuQ'
                            status = 'Available'
                        }
                        @{
                            id = 'GT7dHGEGSve3_To2rGJ8yB'
                            room_id = 'VAOjXdS_Q7pZ3btqTMGNSA'
                            name = 'My Zoom Room2'
                            location_id = 'uOHlx4lwR34sQ4Uxft-Nhg'
                            status = 'Available'
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomRooms

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms*'
            }
        }

        It 'Should not require any parameters' {
            { Get-ZoomRooms } | Should -Not -Throw
        }

        It 'Should use default page size of 30' {
            Get-ZoomRooms

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomRooms -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should accept page_size alias' {
            Get-ZoomRooms -page_size 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should accept UnassignedRooms parameter' {
            { Get-ZoomRooms -UnassignedRooms $true } | Should -Not -Throw
        }

        It 'Should include Status in query when provided' {
            Get-ZoomRooms -Status 'Avalible'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'status=Avalible'
            }
        }

        It 'Should include Type in query when provided' {
            Get-ZoomRooms -Type 'ZoomRoom'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'type=ZoomRoom'
            }
        }

        It 'Should include NextPageToken in query when provided' {
            Get-ZoomRooms -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should include LocationId in query when provided' {
            Get-ZoomRooms -LocationId 'loc123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'location_id=loc123'
            }
        }

        It 'Should accept location_id alias' {
            Get-ZoomRooms -location_id 'loc123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'location_id=loc123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomRooms

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return only rooms array by default' {
            $result = Get-ZoomRooms

            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].name | Should -Be 'My Zoom Room1'
        }

        It 'Should return full response when Full switch is used' {
            $result = Get-ZoomRooms -Full

            $result | Should -Not -BeNullOrEmpty
            $result.page_size | Should -Be 30
            $result.rooms | Should -HaveCount 2
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ rooms = @() }
            }
        }

        It 'Should validate PageSize range (30-300)' {
            { Get-ZoomRooms -PageSize 29 } | Should -Throw
            { Get-ZoomRooms -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomRooms -PageSize 100 } | Should -Not -Throw
        }

        It 'Should validate Status values' {
            { Get-ZoomRooms -Status 'Offline' } | Should -Not -Throw
            { Get-ZoomRooms -Status 'Avalible' } | Should -Not -Throw
            { Get-ZoomRooms -Status 'InMeeting' } | Should -Not -Throw
            { Get-ZoomRooms -Status 'UnderConstruction' } | Should -Not -Throw
            { Get-ZoomRooms -Status 'InvalidStatus' } | Should -Throw
        }

        It 'Should validate Type values' {
            { Get-ZoomRooms -Type 'ZoomRoom' } | Should -Not -Throw
            { Get-ZoomRooms -Type 'SchedulingDisplayOnly' } | Should -Not -Throw
            { Get-ZoomRooms -Type 'DigitalSignageOnly' } | Should -Not -Throw
            { Get-ZoomRooms -Type 'InvalidType' } | Should -Throw
        }

        It 'Should accept UnassignedRooms as boolean' {
            { Get-ZoomRooms -UnassignedRooms $true } | Should -Not -Throw
            { Get-ZoomRooms -UnassignedRooms $false } | Should -Not -Throw
        }

        It 'Should accept pipeline input for PageSize by property name' {
            [PSCustomObject]@{ PageSize = 100 } | Get-ZoomRooms

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }
    }

    Context 'When filtering rooms' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    rooms = @(
                        @{
                            id = 'room1'
                            name = 'Available Room'
                            status = 'Available'
                            location_id = 'loc123'
                        }
                    )
                }
            }
        }

        It 'Should filter by status' {
            $result = Get-ZoomRooms -Status 'Avalible'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'status=Avalible'
            }
        }

        It 'Should filter by location' {
            $result = Get-ZoomRooms -LocationId 'loc123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'location_id=loc123'
            }
        }

        It 'Should filter by type' {
            $result = Get-ZoomRooms -Type 'ZoomRoom'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'type=ZoomRoom'
            }
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Unauthorized'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomRooms } | Should -Throw
        }
    }
}
