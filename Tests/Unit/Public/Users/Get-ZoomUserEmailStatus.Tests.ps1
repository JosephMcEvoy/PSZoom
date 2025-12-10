BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserEmailStatus' {
    Context 'When verifying registered email' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    existed_email = $true
                }
            }
        }

        It 'Should return email status' {
            $result = Get-ZoomUserEmailStatus -Email 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should indicate email exists' {
            $result = Get-ZoomUserEmailStatus -Email 'registered@example.com'
            $result.existed_email | Should -Be $true
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/email'
                $Method | Should -Be 'GET'
                return @{ existed_email = $true }
            }

            Get-ZoomUserEmailStatus -Email 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include email in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'email='
                $Uri.ToString() | Should -Match 'user%40example\.com'
                return @{ existed_email = $true }
            }

            Get-ZoomUserEmailStatus -Email 'user@example.com'
        }
    }

    Context 'When verifying unregistered email' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    existed_email = $false
                }
            }
        }

        It 'Should indicate email does not exist' {
            $result = Get-ZoomUserEmailStatus -Email 'unregistered@example.com'
            $result.existed_email | Should -Be $false
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed_email = $true }
            }
        }

        It 'Should accept Email from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserEmailStatus
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process single email from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserEmailStatus
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed_email = $true }
            }
        }

        It 'Should accept EmailAddress alias' {
            { Get-ZoomUserEmailStatus -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias' {
            { Get-ZoomUserEmailStatus -Id 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept UserId alias' {
            { Get-ZoomUserEmailStatus -UserId 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ existed_email = $true }
            }
        }

        It 'Should require Email parameter' {
            { Get-ZoomUserEmailStatus } | Should -Throw
        }

        It 'Should accept Email as positional parameter' {
            { Get-ZoomUserEmailStatus 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept valid email format' {
            { Get-ZoomUserEmailStatus -Email 'valid.email@domain.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid email format')
            }

            { Get-ZoomUserEmailStatus -Email 'invalid-email' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Get-ZoomUserEmailStatus -Email 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
