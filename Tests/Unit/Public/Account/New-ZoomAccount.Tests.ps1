BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomAccount' {
    Context 'When creating a new sub account' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'abc123'
                    owner_email = 'owner@company.com'
                    created_at = '2023-01-01T00:00:00Z'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password 'Test123!'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/accounts'
            }
        }

        It 'Should use POST method' {
            New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password 'Test123!'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password 'Test123!'
            $result.id | Should -Be 'abc123'
        }

        It 'Should accept optional AccountName parameter' {
            { New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password 'Test123!' -AccountName 'Test Company' } | Should -Not -Throw
        }

        It 'Should accept optional VanityUrl parameter' {
            { New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password 'Test123!' -VanityUrl 'testcompany' } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept pipeline input by property name' {
            $input = [PSCustomObject]@{
                FirstName = 'John'
                LastName = 'Doe'
                Email = 'john@company.com'
                Password = 'Test123!'
            }
            $input | New-ZoomAccount
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
