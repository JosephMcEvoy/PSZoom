BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Connect-PSZoom' {
    BeforeAll {
        # Store original values
        $originalToken = $script:PSZoomToken
        $originalURI = $script:ZoomURI
    }

    AfterAll {
        # Restore original values
        $script:PSZoomToken = $originalToken
        $script:ZoomURI = $originalURI
    }

    Context 'When using APIKey parameter set' {
        BeforeEach {
            Mock New-OAuthToken -ModuleName PSZoom {
                return (ConvertTo-SecureString 'mock-oauth-token' -AsPlainText -Force)
            }
        }

        It 'Should call New-OAuthToken with correct parameters' {
            Connect-PSZoom -AccountID 'test-account' -ClientID 'test-client' -ClientSecret 'test-secret'

            Should -Invoke New-OAuthToken -ModuleName PSZoom -ParameterFilter {
                $AccountID -eq 'test-account' -and
                $ClientID -eq 'test-client' -and
                $ClientSecret -eq 'test-secret'
            }
        }

        It 'Should set ZoomURI to default Zoom.us' {
            Connect-PSZoom -AccountID 'test-account' -ClientID 'test-client' -ClientSecret 'test-secret'

            $script:ZoomURI | Should -Be 'Zoom.us'
        }

        It 'Should accept Zoomgov.com as APIConnection' {
            Connect-PSZoom -AccountID 'test-account' -ClientID 'test-client' -ClientSecret 'test-secret' -APIConnection 'Zoomgov.com'

            $script:ZoomURI | Should -Be 'Zoomgov.com'
        }

        It 'Should set PSZoomToken after successful connection' {
            Connect-PSZoom -AccountID 'test-account' -ClientID 'test-client' -ClientSecret 'test-secret'

            $script:PSZoomToken | Should -Not -BeNullOrEmpty
            $script:PSZoomToken | Should -BeOfType [securestring]
        }
    }

    Context 'When using Token parameter set' {
        It 'Should accept string token and convert to SecureString' {
            Connect-PSZoom -Token 'plain-text-token'

            $script:PSZoomToken | Should -BeOfType [securestring]
        }

        It 'Should accept SecureString token directly' {
            $secureToken = ConvertTo-SecureString 'secure-token' -AsPlainText -Force
            Connect-PSZoom -Token $secureToken

            $script:PSZoomToken | Should -BeOfType [securestring]
        }

        It 'Should not call New-OAuthToken when using Token parameter' {
            Mock New-OAuthToken -ModuleName PSZoom { throw 'Should not be called' }

            { Connect-PSZoom -Token 'direct-token' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require AccountID for APIKey parameter set' {
            { Connect-PSZoom -ClientID 'test' -ClientSecret 'test' } | Should -Throw
        }

        It 'Should require ClientID for APIKey parameter set' {
            { Connect-PSZoom -AccountID 'test' -ClientSecret 'test' } | Should -Throw
        }

        It 'Should require ClientSecret for APIKey parameter set' {
            { Connect-PSZoom -AccountID 'test' -ClientID 'test' } | Should -Throw
        }

        It 'Should accept APIKey alias for ClientID' {
            Mock New-OAuthToken -ModuleName PSZoom {
                return (ConvertTo-SecureString 'token' -AsPlainText -Force)
            }

            { Connect-PSZoom -AccountID 'test' -APIKey 'test-key' -ClientSecret 'test' } | Should -Not -Throw
        }

        It 'Should accept APISecret alias for ClientSecret' {
            Mock New-OAuthToken -ModuleName PSZoom {
                return (ConvertTo-SecureString 'token' -AsPlainText -Force)
            }

            { Connect-PSZoom -AccountID 'test' -ClientID 'test' -APISecret 'test-secret' } | Should -Not -Throw
        }
    }

    Context 'APIConnection validation' {
        BeforeEach {
            Mock New-OAuthToken -ModuleName PSZoom {
                return (ConvertTo-SecureString 'token' -AsPlainText -Force)
            }
        }

        It 'Should accept Zoom.Us as valid APIConnection' {
            { Connect-PSZoom -AccountID 'test' -ClientID 'test' -ClientSecret 'test' -APIConnection 'Zoom.Us' } | Should -Not -Throw
        }

        It 'Should accept Zoomgov.com as valid APIConnection' {
            { Connect-PSZoom -AccountID 'test' -ClientID 'test' -ClientSecret 'test' -APIConnection 'Zoomgov.com' } | Should -Not -Throw
        }

        It 'Should reject invalid APIConnection values' {
            { Connect-PSZoom -AccountID 'test' -ClientID 'test' -ClientSecret 'test' -APIConnection 'Invalid' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should handle OAuth token retrieval failure' {
            Mock New-OAuthToken -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Failed to get token')
            }

            { Connect-PSZoom -AccountID 'bad-account' -ClientID 'bad-client' -ClientSecret 'bad-secret' -ErrorAction Stop } | Should -Throw
        }
    }
}
