BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'New-OAuthToken' {
    BeforeAll {
        InModuleScope PSZoom {
            $script:ZoomURI = 'zoom.us'
        }
    }

    Context 'When requesting OAuth token' {
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{
                    access_token = 'mock-access-token-12345'
                    token_type = 'bearer'
                    expires_in = 3600
                }
            }
        }

        It 'Should return a SecureString token' {
            $result = New-OAuthToken -AccountID 'test-account' -ClientID 'test-client' -ClientSecret 'test-secret' -APIConnection 'Zoom.us'

            $result | Should -BeOfType [securestring]
        }

        It 'Should call Invoke-RestMethod with POST method' {
            New-OAuthToken -AccountID 'test-account' -ClientID 'test-client' -ClientSecret 'test-secret' -APIConnection 'Zoom.us'

            Should -Invoke Invoke-RestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include Basic Authorization header' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($Headers)
                $Headers['Authorization'] | Should -BeLike 'Basic *'
                return @{
                    access_token = 'token'
                    token_type = 'bearer'
                }
            }

            New-OAuthToken -AccountID 'test' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us'
            Should -Invoke Invoke-RestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should properly encode ClientID and ClientSecret in Basic auth' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($Headers)
                # 'testclient:testsecret' base64 encoded = 'dGVzdGNsaWVudDp0ZXN0c2VjcmV0'
                $expectedAuth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('testclient:testsecret'))
                $Headers['Authorization'] | Should -Be $expectedAuth
                return @{
                    access_token = 'token'
                }
            }

            New-OAuthToken -AccountID 'account' -ClientID 'testclient' -ClientSecret 'testsecret' -APIConnection 'Zoom.us'
        }

        It 'Should construct correct OAuth URL with account_id' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'account_id=myaccount'
                return @{
                    access_token = 'token'
                }
            }

            New-OAuthToken -AccountID 'myaccount' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us'
        }

        It 'Should use grant_type=account_credentials in URL' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'grant_type=account_credentials'
                return @{
                    access_token = 'token'
                }
            }

            New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us'
        }
    }

    Context 'APIConnection handling' {
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{
                    access_token = 'token'
                }
            }
        }

        It 'Should use Zoom.us domain for standard Zoom' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'zoom\.us'
                return @{ access_token = 'token' }
            }

            New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us'
        }

        It 'Should use Zoomgov.com domain for government cloud' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'Zoomgov\.com'
                return @{ access_token = 'token' }
            }

            New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoomgov.com'
        }

        It 'Should set script ZoomURI variable' {
            New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoomgov.com'

            InModuleScope PSZoom {
                $script:ZoomURI | Should -Be 'Zoomgov.com'
            }
        }
    }

    Context 'Parameter validation' {
        It 'Should require AccountID parameter' {
            { New-OAuthToken -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us' } | Should -Throw
        }

        It 'Should require ClientID parameter' {
            { New-OAuthToken -AccountID 'account' -ClientSecret 'secret' -APIConnection 'Zoom.us' } | Should -Throw
        }

        It 'Should require ClientSecret parameter' {
            { New-OAuthToken -AccountID 'account' -ClientID 'client' -APIConnection 'Zoom.us' } | Should -Throw
        }

        It 'Should validate APIConnection to accepted values' {
            { New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Invalid' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate errors from Invoke-RestMethod' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Connection failed')
            }

            { New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us' -ErrorAction Stop } | Should -Throw
        }

        It 'Should throw when response lacks access_token' {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{
                    error = 'invalid_client'
                    reason = 'Invalid credentials'
                }
            }

            { New-OAuthToken -AccountID 'account' -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PSZoom {
                return @{
                    access_token = 'pipeline-token'
                }
            }
        }

        It 'Should accept AccountID from pipeline' {
            $result = 'pipeline-account' | New-OAuthToken -ClientID 'client' -ClientSecret 'secret' -APIConnection 'Zoom.us'
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
