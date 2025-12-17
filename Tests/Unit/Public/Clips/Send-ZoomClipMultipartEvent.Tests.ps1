BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Send-ZoomClipMultipartEvent' {
    Context 'When sending a multipart upload event' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    status = 'success'
                    message = 'Event processed'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Send-ZoomClipMultipartEvent

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/clips/files/multipart/upload_events$'
            }
        }

        It 'Should use POST method' {
            Send-ZoomClipMultipartEvent

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = Send-ZoomClipMultipartEvent

            $result.status | Should -Be 'success'
        }
    }
}
