BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPersonalMeetingRoomName' {
    Context 'When checking vanity name availability' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    existed = $false
                }
            }
        }

        It 'Should return availability status' {
            $result = Get-ZoomPersonalMeetingRoomName -VanityName 'JoesRoom'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should indicate vanity name does not exist' {
            $result = Get-ZoomPersonalMeetingRoomName -VanityName 'AvailableRoom'
            $result.existed | Should -Be $false
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/vanity_name'
                $Method | Should -Be 'GET'
                return @{ existed = $false }
            }

            Get-ZoomPersonalMeetingRoomName -VanityName 'TestRoom'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include vanity_name in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'vanity_name='
                return @{ existed = $false }
            }

            Get-ZoomPersonalMeetingRoomName -VanityName 'MyRoom'
        }
    }

    Context 'When vanity name exists' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    existed = $true
                }
            }
        }

        It 'Should indicate vanity name exists' {
            $result = Get-ZoomPersonalMeetingRoomName -VanityName 'TakenRoom'
            $result.existed | Should -Be $true
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed = $false }
            }
        }

        It 'Should accept VanityName from pipeline' {
            $result = 'TestRoom' | Get-ZoomPersonalMeetingRoomName
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple VanityNames from pipeline' {
            $results = @('Room1', 'Room2', 'Room3') | Get-ZoomPersonalMeetingRoomName
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should accept object with VanityName property from pipeline' {
            $roomObject = [PSCustomObject]@{ VanityName = 'TestRoom' }
            $result = $roomObject | Get-ZoomPersonalMeetingRoomName
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed = $false }
            }
        }

        It 'Should accept vanity_name alias' {
            { Get-ZoomPersonalMeetingRoomName -vanity_name 'TestRoom' } | Should -Not -Throw
        }

        It 'Should accept vanitynames alias' {
            { Get-ZoomPersonalMeetingRoomName -vanitynames 'TestRoom' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed = $false }
            }
        }

        It 'Should require VanityName parameter' {
            { Get-ZoomPersonalMeetingRoomName } | Should -Throw
        }

        It 'Should accept VanityName as positional parameter' {
            { Get-ZoomPersonalMeetingRoomName 'TestRoom' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid vanity name')
            }

            { Get-ZoomPersonalMeetingRoomName -VanityName 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
