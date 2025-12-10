BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Connect-ZoomRoomMeeting' {
    Context 'When connecting a Zoom Room to a meeting' {
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
            Connect-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/meetings'
            }
        }

        It 'Should require RoomId parameter' {
            { Connect-ZoomRoomMeeting -MeetingNumber '1234567890' } | Should -Throw
        }

        It 'Should accept RoomId from pipeline' {
            'room123' | Connect-ZoomRoomMeeting -MeetingNumber '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept zr_id alias for RoomId' {
            Connect-ZoomRoomMeeting -zr_id 'room123' -MeetingNumber '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }


        It 'Should use POST method' {
            Connect-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = Connect-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890'

            $result | Should -Not -BeNullOrEmpty
            $result.jsonrpc | Should -Be '2.0'
            $result.result.room_id | Should -Be '63UtYMhSQZaBRPCNRXrD8A'
        }

        It 'Should handle multiple room IDs' {
            Connect-ZoomRoomMeeting -RoomId 'room123', 'room456' -MeetingNumber '1234567890'

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
            { Connect-ZoomRoomMeeting -RoomId 'room123' -Password 'Pass123' } | Should -Not -Throw
        }

        It 'Should accept password with special characters @-_*' {
            { Connect-ZoomRoomMeeting -RoomId 'room123' -Password 'P@ss-_*123' } | Should -Not -Throw
        }

        It 'Should accept password up to 10 characters' {
            { Connect-ZoomRoomMeeting -RoomId 'room123' -Password '1234567890' } | Should -Not -Throw
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Room not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Connect-ZoomRoomMeeting -RoomId 'room123' -MeetingNumber '1234567890' } | Should -Throw
        }
    }
}
