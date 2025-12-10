BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneExternalContact' {
    Context 'When retrieving a specific external contact' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'contact123'
                    first_name = 'John'
                    last_name = 'Doe'
                    phone_number = '+14155551234'
                }
            }
        }

        It 'Should return an external contact' {
            $result = Get-ZoomPhoneExternalContact -ContactId 'contact123'
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'contact123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/external_contacts/contact123'
                return @{ id = 'contact123' }
            }

            Get-ZoomPhoneExternalContact -ContactId 'contact123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'contact123' }
            }

            Get-ZoomPhoneExternalContact -ContactId 'contact123'
        }
    }

    Context 'When retrieving multiple external contacts' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                if ($Uri -match 'contact123') {
                    return @{ id = 'contact123'; first_name = 'John' }
                } elseif ($Uri -match 'contact456') {
                    return @{ id = 'contact456'; first_name = 'Jane' }
                }
            }
        }

        It 'Should handle multiple ContactIds' {
            $result = Get-ZoomPhoneExternalContact -ContactId 'contact123', 'contact456'
            $result.Count | Should -Be 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'contact123' }
            }
        }

        It 'Should accept ContactId from pipeline' {
            { 'contact123' | Get-ZoomPhoneExternalContact } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $contactObject = [PSCustomObject]@{ id = 'contact123' }
            { $contactObject | Get-ZoomPhoneExternalContact } | Should -Not -Throw
        }

        It 'Should accept object with contactId property from pipeline' {
            $contactObject = [PSCustomObject]@{ contactId = 'contact123' }
            { $contactObject | Get-ZoomPhoneExternalContact } | Should -Not -Throw
        }

        It 'Should accept object with contact_id property from pipeline' {
            $contactObject = [PSCustomObject]@{ contact_id = 'contact123' }
            { $contactObject | Get-ZoomPhoneExternalContact } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'contact123' }
            }
        }

        It 'Should accept contactId alias' {
            { Get-ZoomPhoneExternalContact -contactId 'contact123' } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Get-ZoomPhoneExternalContact -id 'contact123' } | Should -Not -Throw
        }

        It 'Should accept contact_id alias' {
            { Get-ZoomPhoneExternalContact -contact_id 'contact123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require ContactId parameter' {
            { Get-ZoomPhoneExternalContact -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('External contact not found')
            }

            { Get-ZoomPhoneExternalContact -ContactId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
