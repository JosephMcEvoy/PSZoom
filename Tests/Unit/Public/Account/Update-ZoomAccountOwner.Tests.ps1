BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state within module scope
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomAccountOwner' {
    Context 'When updating account owner' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/owner*'
            }
        }

        It 'Should use PUT method' {
            Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Should include email in request body' {
            Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body -ne $null -and
                $Body.email -eq 'newowner@example.com'
            }
        }

        It 'Should return true when response is null (successful update)' {
            $result = Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com'
            $result | Should -BeTrue
        }

        It 'Should return response when response is not null' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    owner = @{
                        email = 'newowner@example.com'
                        id = 'user123'
                    }
                }
            }
            $result = Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com'
            $result.owner.email | Should -Be 'newowner@example.com'
        }

        It 'Should handle different email formats' {
            $emails = @(
                'user@example.com',
                'user.name@example.com',
                'user+tag@example.co.uk'
            )

            foreach ($email in $emails) {
                Update-ZoomAccountOwner -AccountId 'abc123' -Email $email
            }

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times $emails.Count
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should support WhatIf' {
            Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when Confirm is bypassed' {
            Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept pipeline input by value (AccountId)' {
            'abc123' | Update-ZoomAccountOwner -Email 'newowner@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*abc123*'
            }
        }

        It 'Should accept pipeline input by property name (AccountId and Email)' {
            $input = [PSCustomObject]@{
                AccountId = 'xyz789'
                Email = 'newowner@example.com'
            }
            $input | Update-ZoomAccountOwner
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*xyz789*' -and
                $Body.email -eq 'newowner@example.com'
            }
        }

        It 'Should accept pipeline input by property name (account_id alias)' {
            $input = [PSCustomObject]@{
                account_id = 'test456'
                Email = 'owner@test.com'
            }
            $input | Update-ZoomAccountOwner
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*test456*'
            }
        }

        It 'Should accept pipeline input by property name (id alias)' {
            $input = [PSCustomObject]@{
                id = 'id999'
                Email = 'admin@test.com'
            }
            $input | Update-ZoomAccountOwner
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*id999*'
            }
        }

        It 'Should process multiple accounts from pipeline' {
            $accounts = @(
                [PSCustomObject]@{ AccountId = 'acc1'; Email = 'owner1@example.com' }
                [PSCustomObject]@{ AccountId = 'acc2'; Email = 'owner2@example.com' }
                [PSCustomObject]@{ AccountId = 'acc3'; Email = 'owner3@example.com' }
            )

            $accounts | Update-ZoomAccountOwner
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should require AccountId parameter' {
            { Update-ZoomAccountOwner -Email 'newowner@example.com' } | Should -Throw
        }

        It 'Should require Email parameter' {
            { Update-ZoomAccountOwner -AccountId 'abc123' } | Should -Throw
        }

        It 'Should accept both required parameters' {
            { Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Bad Request')
            }

            { Update-ZoomAccountOwner -AccountId 'abc123' -Email 'newowner@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle 404 not found error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('The remote server returned an error: (404) Not Found.')
            }

            { Update-ZoomAccountOwner -AccountId 'invalid' -Email 'newowner@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle invalid email format error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('The remote server returned an error: (400) Bad Request. Invalid email address.')
            }

            { Update-ZoomAccountOwner -AccountId 'abc123' -Email 'invalid-email' -ErrorAction Stop } | Should -Throw
        }
    }
}
