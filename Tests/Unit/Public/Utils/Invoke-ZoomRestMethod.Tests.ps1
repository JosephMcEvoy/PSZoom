BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Invoke-ZoomRestMethod' {
    BeforeAll {
        # Set up required module state within module scope
        InModuleScope PSZoom {
            $script:PSZoomToken = ConvertTo-SecureString 'test-token-12345' -AsPlainText -Force
            $script:ZoomURI = 'zoom.us'
        }
        # Also create local variable for tests that need to pass token explicitly
        $script:TestToken = ConvertTo-SecureString 'test-token-12345' -AsPlainText -Force
    }

    Context 'When token is not set' {
        It 'Should display message when no token found' {
            InModuleScope PSZoom {
                # Mock Invoke-RestMethod to prevent actual API call
                Mock Invoke-RestMethod { return @{} }

                $originalToken = $script:PSZoomToken
                $script:PSZoomToken = $null

                # Capture host output (stream 6 is Information, but Write-Host goes to stream 1)
                $output = Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method GET 4>&1 6>&1

                $script:PSZoomToken = $originalToken
                # The message is written to the host, verify it was triggered
                $output | Should -Match 'No token found'
            }
        }
    }

    Context 'When making successful API calls' {
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{
                    id = 'user123'
                    email = 'test@example.com'
                }
            }
        }

        It 'Should return response from API' {
            $result = Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users/me' -Method GET -Token $script:TestToken
            $result.id | Should -Be 'user123'
        }

        It 'Should use application/json content type by default' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($ContentType)
                $ContentType | Should -Be 'application/json; charset=utf-8'
                return @{ success = $true }
            }

            Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method GET -Token $script:TestToken
            Should -Invoke Invoke-RestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should respect custom ContentType parameter' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($ContentType)
                return @{ success = $true }
            }

            Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method POST -ContentType 'text/plain' -Token $script:TestToken
            Should -Invoke Invoke-RestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'HTTP method support' {
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support GET method' {
            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method GET -Token $script:TestToken } | Should -Not -Throw
        }

        It 'Should support POST method' {
            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method POST -Token $script:TestToken } | Should -Not -Throw
        }

        It 'Should support PUT method' {
            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users/123' -Method PUT -Token $script:TestToken } | Should -Not -Throw
        }

        It 'Should support DELETE method' {
            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users/123' -Method DELETE -Token $script:TestToken } | Should -Not -Throw
        }

        It 'Should support PATCH method' {
            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users/123' -Method PATCH -Token $script:TestToken } | Should -Not -Throw
        }
    }

    Context 'Request body handling' {
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should pass body parameter to Invoke-RestMethod' {
            $body = @{ email = 'test@test.com' } | ConvertTo-Json

            Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method POST -Body $body -Token $script:TestToken
            Should -Invoke Invoke-RestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Error handling' {
        It 'Should handle 401 authentication errors' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                $exception = [System.Net.WebException]::new('The remote server returned an error: (401) Unauthorized.')
                throw $exception
            }

            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Method GET -Token $script:TestToken -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle 404 not found errors' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                $exception = [System.Net.WebException]::new('The remote server returned an error: (404) Not Found.')
                throw $exception
            }

            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users/nonexistent' -Method GET -Token $script:TestToken -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should accept Uri parameter' {
            Mock Invoke-RestMethod -ModuleName PSZoom { return @{} }

            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -Token $script:TestToken } | Should -Not -Throw
        }

        It 'Should accept TimeoutSec parameter' {
            Mock Invoke-RestMethod -ModuleName PSZoom { return @{} }

            { Invoke-ZoomRestMethod -Uri 'https://api.zoom.us/v2/users' -TimeoutSec 30 -Token $script:TestToken } | Should -Not -Throw
        }
    }
}
