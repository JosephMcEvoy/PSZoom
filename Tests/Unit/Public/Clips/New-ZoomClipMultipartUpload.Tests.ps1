BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomClipMultipartUpload' {
    Context 'When creating a multipart upload session' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    upload_id = 'multipart123'
                    upload_urls = @(
                        'https://upload.zoom.us/part1',
                        'https://upload.zoom.us/part2'
                    )
                }
            }
        }

        It 'Should call API with correct endpoint' {
            New-ZoomClipMultipartUpload

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/clips/files/multipart$'
            }
        }

        It 'Should use POST method' {
            New-ZoomClipMultipartUpload

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return the response object' {
            $result = New-ZoomClipMultipartUpload

            $result.upload_id | Should -Be 'multipart123'
            $result.upload_urls.Count | Should -Be 2
        }
    }
}
