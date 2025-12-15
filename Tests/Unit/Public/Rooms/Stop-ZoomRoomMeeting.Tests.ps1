BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Stop-ZoomRoomMeeting' {
    Context 'When stopping a Zoom Room meeting' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    jsonrpc = '2.0'
                    result = @{
                        room_id = '63UtYMhSQZaBRPCNRXrD8A'
                        send_at = '2025-01-15T10:00:00Z'
                    }
                    id = '49cf01a4-517e-4a49-b4d6-07237c38b749'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Stop-ZoomRoomMeeting -RoomId 'room123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/meetings'
            }
        }

        It 'Should require RoomId parameter' {
            { Stop-ZoomRoomMeeting } | Should -Throw
        }

        It 'Should accept RoomId from pipeline' {
            'room123' | Stop-ZoomRoomMeeting

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept zr_id alias for RoomId' {
            Stop-ZoomRoomMeeting -zr_id 'room123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept roomids alias for RoomId' {
            Stop-ZoomRoomMeeting -roomids 'room123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }


        It 'Should use POST method' {
            Stop-ZoomRoomMeeting -RoomId 'room123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = Stop-ZoomRoomMeeting -RoomId 'room123'

            $result | Should -Not -BeNullOrEmpty
            $result.jsonrpc | Should -Be '2.0'
            $result.result.room_id | Should -Be '63UtYMhSQZaBRPCNRXrD8A'
        }

        It 'Should handle multiple room IDs' {
            Stop-ZoomRoomMeeting -RoomId 'room123', 'room456'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should construct correct URI for each room ID' {
            Stop-ZoomRoomMeeting -RoomId 'room123', 'room456'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/meetings'
            }

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room456/meetings'
            }
        }

        It 'Should process rooms from pipeline' {
            $rooms = @('room123', 'room456', 'room789')
            $rooms | Stop-ZoomRoomMeeting

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Room not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Stop-ZoomRoomMeeting -RoomId 'room123' } | Should -Throw
        }
    }

}
