BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomWebinarLiveStream' {
    Context 'When updating live stream settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomWebinarLiveStream -WebinarId 1234567890 -StreamUrl 'rtmp://live.example.com/app' -StreamKey 'key123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/livestream*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomWebinarLiveStream -WebinarId 1234567890 -StreamUrl 'rtmp://live.example.com/app' -StreamKey 'key123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should require WebinarId parameter' {
            { Update-ZoomWebinarLiveStream -StreamUrl 'rtmp://live.example.com/app' -StreamKey 'key123' } | Should -Throw
        }

        It 'Should require StreamUrl parameter' {
            { Update-ZoomWebinarLiveStream -WebinarId 1234567890 -StreamKey 'key123' } | Should -Throw
        }

        It 'Should require StreamKey parameter' {
            { Update-ZoomWebinarLiveStream -WebinarId 1234567890 -StreamUrl 'rtmp://live.example.com/app' } | Should -Throw
        }

        It 'Should accept optional PageUrl parameter' {
            { Update-ZoomWebinarLiveStream -WebinarId 1234567890 -StreamUrl 'rtmp://live.example.com/app' -StreamKey 'key123' -PageUrl 'https://example.com/live' } | Should -Not -Throw
        }
    }
}
