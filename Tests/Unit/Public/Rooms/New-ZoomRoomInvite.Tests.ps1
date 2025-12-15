BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomRoomInvite' {
    Context 'When inviting contacts to a Zoom Room meeting' {
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
            New-ZoomRoomInvite -RoomId 'room123' -callee 'user123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/room123/zrclient'
            }
        }

        It 'Should require RoomId parameter' {
            { New-ZoomRoomInvite -callee 'user123' } | Should -Throw
        }

        It 'Should require callee parameter' {
            { New-ZoomRoomInvite -RoomId 'room123' } | Should -Throw
        }

        It 'Should accept RoomId from pipeline' {
            'room123' | New-ZoomRoomInvite -callee 'user123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept zr_id alias for RoomId' {
            New-ZoomRoomInvite -zr_id 'room123' -callee 'user123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias for callee' {
            New-ZoomRoomInvite -RoomId 'room123' -id 'user123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }


        It 'Should use POST method' {
            New-ZoomRoomInvite -RoomId 'room123' -callee 'user123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = New-ZoomRoomInvite -RoomId 'room123' -callee 'user123'

            $result | Should -Not -BeNullOrEmpty
            $result.jsonrpc | Should -Be '2.0'
            $result.result.room_id | Should -Be '63UtYMhSQZaBRPCNRXrD8A'
        }
    }


    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Room not found'
            }
        }

        It 'Should throw error when API call fails' {
            { New-ZoomRoomInvite -RoomId 'room123' -callee 'user123' } | Should -Throw
        }
    }

}
