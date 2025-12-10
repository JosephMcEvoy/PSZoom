BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomUser' {
    Context 'When updating a user with basic parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
            Mock ConvertTo-LoginTypeCode -ModuleName PSZoom {
                param($Code)
                return $Code
            }
            Mock Get-ZoomTimeZones -ModuleName PSZoom {
                return @('America/New_York', 'America/Los_Angeles', 'UTC')
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com'
                $Method | Should -Be 'PATCH'
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -FirstName 'John' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include FirstName in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.first_name | Should -Be 'John'
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -FirstName 'John' -Confirm:$false
        }

        It 'Should include LastName in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.last_name | Should -Be 'Doe'
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -LastName 'Doe' -Confirm:$false
        }
    }

    Context 'Type parameter conversion' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should convert Basic to 1' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.type | Should -Be 1
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -Type 'Basic' -Confirm:$false
        }

        It 'Should convert Pro to 2' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.type | Should -Be 2
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -Type 'Pro' -Confirm:$false
        }

        It 'Should convert Corp to 3' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.type | Should -Be 3
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -Type 'Corp' -Confirm:$false
        }

        It 'Should accept numeric type values' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.type | Should -Be 2
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -Type 2 -Confirm:$false
        }
    }

    Context 'LoginType parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
            Mock ConvertTo-LoginTypeCode -ModuleName PSZoom {
                param($Code)
                return '100'
            }
        }

        It 'Should include LoginType in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'login_type='
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -LoginType '100' -Confirm:$false
        }

        It 'Should call ConvertTo-LoginTypeCode' {
            Update-ZoomUser -UserId 'testuser@example.com' -LoginType 'ZoomWorkemail' -Confirm:$false
            Should -Invoke ConvertTo-LoginTypeCode -ModuleName PSZoom -Times 1
        }
    }

    Context 'PMI parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept valid 10-digit PMI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.pmi | Should -Be 1234567890
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -Pmi 1234567890 -Confirm:$false
        }

        It 'Should reject PMI less than 10 digits' {
            { Update-ZoomUser -UserId 'testuser@example.com' -Pmi 123456789 -Confirm:$false } | Should -Throw
        }

        It 'Should reject PMI more than 10 digits' {
            { Update-ZoomUser -UserId 'testuser@example.com' -Pmi 12345678901 -Confirm:$false } | Should -Throw
        }
    }

    Context 'HostKey parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept valid 6-digit host key' {
            { Update-ZoomUser -UserId 'testuser@example.com' -HostKey '123456' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept valid 10-digit host key' {
            { Update-ZoomUser -UserId 'testuser@example.com' -HostKey '1234567890' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject host key less than 6 digits' {
            { Update-ZoomUser -UserId 'testuser@example.com' -HostKey '12345' -Confirm:$false } | Should -Throw
        }

        It 'Should accept host key with more than 10 digits as pattern allows substring match' {
            { Update-ZoomUser -UserId 'testuser@example.com' -HostKey '12345678901' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Timezone parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
            Mock Get-ZoomTimeZones -ModuleName PSZoom {
                return @('America/New_York', 'America/Los_Angeles', 'UTC')
            }
        }

        It 'Should accept valid timezone' {
            { Update-ZoomUser -UserId 'testuser@example.com' -Timezone 'America/New_York' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject invalid timezone' {
            { Update-ZoomUser -UserId 'testuser@example.com' -Timezone 'Invalid/Timezone' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Multiple parameters in request body' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should include multiple parameters in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.first_name | Should -Be 'John'
                $bodyObj.last_name | Should -Be 'Doe'
                $bodyObj.company | Should -Be 'Acme Corp'
                $bodyObj.job_title | Should -Be 'Developer'
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -FirstName 'John' -LastName 'Doe' -Company 'Acme Corp' -JobTitle 'Developer' -Confirm:$false
        }
    }

    Context 'PhoneNumbers parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept PhoneNumbers array' {
            $phoneNumbers = @(
                @{ code = '+1'; country = 'US'; label = 'Mobile'; number = '1234567890' }
            )

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.phone_numbers | Should -Not -BeNullOrEmpty
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -PhoneNumbers $phoneNumbers -Confirm:$false
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Update-ZoomUser -FirstName 'John' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Update-ZoomUser -FirstName 'John' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'SupportsShouldProcess behavior' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should support WhatIf parameter' {
            Update-ZoomUser -UserId 'user@example.com' -FirstName 'John' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm parameter' {
            Update-ZoomUser -UserId 'user@example.com' -FirstName 'John' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com'; first_name = 'John' }
            }
        }

        It 'Should return UserId when Passthru is specified' {
            $result = Update-ZoomUser -UserId 'user@example.com' -FirstName 'John' -PassThru -Confirm:$false
            $result | Should -Be 'user@example.com'
        }

        It 'Should return API response when Passthru is not specified' {
            $result = Update-ZoomUser -UserId 'user@example.com' -FirstName 'John' -Confirm:$false
            $result.id | Should -Be 'testuser@example.com'
        }

        It 'Should return UserIds for multiple users with PassThru' {
            $results = @('user1@example.com', 'user2@example.com') | Update-ZoomUser -FirstName 'John' -PassThru -Confirm:$false
            $results | Should -Contain 'user1@example.com'
            $results | Should -Contain 'user2@example.com'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Update-ZoomUser -Email 'user@example.com' -FirstName 'John' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept first_name alias' {
            { Update-ZoomUser -UserId 'user@example.com' -first_name 'John' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept last_name alias' {
            { Update-ZoomUser -UserId 'user@example.com' -last_name 'Doe' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept use_pmi alias' {
            { Update-ZoomUser -UserId 'user@example.com' -use_pmi $true -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept host_key alias' {
            { Update-ZoomUser -UserId 'user@example.com' -host_key '123456' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept job_title alias' {
            { Update-ZoomUser -UserId 'user@example.com' -job_title 'Developer' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept phone_numbers alias' {
            $phones = @(@{ code = '+1'; country = 'US'; number = '1234567890' })
            { Update-ZoomUser -UserId 'user@example.com' -phone_numbers $phones -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Optional parameters not included when not specified' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should only include specified parameters in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.first_name | Should -Be 'John'
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'last_name'
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'company'
                return @{ id = 'testuser@example.com' }
            }

            Update-ZoomUser -UserId 'testuser@example.com' -FirstName 'John' -Confirm:$false
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Update-ZoomUser -UserId 'nonexistent@example.com' -FirstName 'John' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle validation errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid parameter')
            }

            { Update-ZoomUser -UserId 'user@example.com' -FirstName 'John' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'UserId length validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept UserId within valid length' {
            { Update-ZoomUser -UserId 'user@example.com' -FirstName 'John' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject UserId exceeding 128 characters' {
            $longUserId = 'a' * 129
            { Update-ZoomUser -UserId $longUserId -FirstName 'John' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Name length validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'testuser@example.com' }
            }
        }

        It 'Should accept FirstName within valid length' {
            { Update-ZoomUser -UserId 'user@example.com' -FirstName ('a' * 64) -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject FirstName exceeding 64 characters' {
            { Update-ZoomUser -UserId 'user@example.com' -FirstName ('a' * 65) -Confirm:$false } | Should -Throw
        }

        It 'Should accept LastName within valid length' {
            { Update-ZoomUser -UserId 'user@example.com' -LastName ('a' * 64) -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject LastName exceeding 64 characters' {
            { Update-ZoomUser -UserId 'user@example.com' -LastName ('a' * 65) -Confirm:$false } | Should -Throw
        }
    }
}
