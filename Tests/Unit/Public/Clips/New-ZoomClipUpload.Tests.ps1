BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomClipUpload' {
    Context 'When creating a clip upload' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    upload_id = 'upload123'
                    upload_url = 'https://upload.zoom.us/clips/upload123'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            New-ZoomClipUpload -Name 'Test Clip'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/clips/files$'
            }
        }

        It 'Should use POST method' {
            New-ZoomClipUpload -Name 'Test Clip'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include name in request body' {
            New-ZoomClipUpload -Name 'Test Clip'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"name"' -and $Body -match 'Test Clip'
            }
        }

        It 'Should include description when provided' {
            New-ZoomClipUpload -Name 'Test Clip' -Description 'A test description'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"description"' -and $Body -match 'A test description'
            }
        }

        It 'Should not include description when not provided' {
            New-ZoomClipUpload -Name 'Test Clip'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -notmatch '"description"'
            }
        }

        It 'Should return the response object' {
            $result = New-ZoomClipUpload -Name 'Test Clip'

            $result.upload_id | Should -Be 'upload123'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ upload_id = 'upload123' }
            }
        }

        It 'Should accept clip_name from pipeline by property name' {
            [PSCustomObject]@{ clip_name = 'Test Clip' } | New-ZoomClipUpload

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ upload_id = 'upload123' }
            }
        }

        It 'Should accept clip_name alias' {
            { New-ZoomClipUpload -clip_name 'Test Clip' } | Should -Not -Throw
        }

        It 'Should accept clip_description alias' {
            { New-ZoomClipUpload -clip_name 'Test' -clip_description 'Description' } | Should -Not -Throw
        }
    }
}
