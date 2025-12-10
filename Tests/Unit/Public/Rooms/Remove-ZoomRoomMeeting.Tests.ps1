BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomRoomMeeting' {
    Context 'When canceling a Zoom Room meeting' {
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
            Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/meetings'
            }
        }

        It 'Should require RoomId parameter' {
            { Remove-ZoomRoomMeeting -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }

        It 'Should require MeetingNumber parameter' {
            { Remove-ZoomRoomMeeting -RoomId 'room123' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }

        It 'Should require Topic parameter' {
            { Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }

        It 'Should require StartTime parameter' {
            { Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -Topic 'Test' -Duration 60 } | Should -Throw
        }

        It 'Should require Duration parameter' {
            { Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' } | Should -Throw
        }

        It 'Should accept RoomId from pipeline' {
            'room123' | Remove-ZoomRoomMeeting -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept zr_id alias for RoomId' {
            Remove-ZoomRoomMeeting -zr_id 'room123' -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept MeetingNumbers alias' {
            Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumbers '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }


        It 'Should use POST method' {
            Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            $result | Should -Not -BeNullOrEmpty
            $result.jsonrpc | Should -Be '2.0'
        }

        It 'Should handle multiple meeting numbers' {
            Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890', '0987654321' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Meeting not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Remove-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Throw
        }
    }

}
