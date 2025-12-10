BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomRoomMeeting' {
    Context 'When scheduling a Zoom Room meeting' {
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
            New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test Meeting' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/meetings'
            }
        }

        It 'Should require RoomId parameter' {
            { New-ZoomRoomMeeting -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }

        It 'Should require Topic parameter' {
            { New-ZoomRoomMeeting -RoomId 'room123' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }

        It 'Should require StartTime parameter' {
            { New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -Duration 60 } | Should -Throw
        }

        It 'Should require Duration parameter' {
            { New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' } | Should -Throw
        }

        It 'Should accept RoomId from pipeline' {
            'room123' | New-ZoomRoomMeeting -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept zr_id alias for RoomId' {
            New-ZoomRoomMeeting -zr_id 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }


        It 'Should use POST method' {
            New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            $result | Should -Not -BeNullOrEmpty
            $result.jsonrpc | Should -Be '2.0'
        }

        It 'Should handle multiple room IDs' {
            New-ZoomRoomMeeting -RoomId 'room123', 'room456' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When validating password parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ jsonrpc = '2.0' }
            }
        }

        It 'Should accept valid password with letters and numbers' {
            { New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 -Password 'Pass123' } | Should -Not -Throw
        }

        It 'Should accept password with special characters @-_*' {
            { New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 -Password 'P@ss-_*123' } | Should -Not -Throw
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Room not found'
            }
        }

        It 'Should throw error when API call fails' {
            { New-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }
    }
}
