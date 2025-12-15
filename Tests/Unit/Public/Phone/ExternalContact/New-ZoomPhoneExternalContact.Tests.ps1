BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomPhoneExternalContact' {
    Context 'When creating an external contact' {
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

        It 'Should create an external contact with required parameters' {
            $result = New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'contact123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/external_contacts'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
        }

        It 'Should include first_name in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.first_name | Should -Be 'John'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
        }

        It 'Should include last_name in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.last_name | Should -Be 'Doe'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
        }

        It 'Should include phone_number in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.phone_number | Should -Be '+14155551234'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
        }
    }

    Context 'When creating with optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'contact123' }
            }
        }

        It 'Should include email when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.email | Should -Be 'john@example.com'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Email 'john@example.com' -Confirm:$false
        }

        It 'Should include company when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.company | Should -Be 'Acme Corp'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Company 'Acme Corp' -Confirm:$false
        }

        It 'Should include job_title when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.job_title | Should -Be 'Manager'
                return @{ id = 'contact123' }
            }

            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -JobTitle 'Manager' -Confirm:$false
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'contact123' }
            }
        }

        It 'Should support WhatIf' {
            { New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'contact123' }
            }
        }

        It 'Should accept first_name alias' {
            { New-ZoomPhoneExternalContact -first_name 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept last_name alias' {
            { New-ZoomPhoneExternalContact -FirstName 'John' -last_name 'Doe' -PhoneNumber '+14155551234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept phone_number alias' {
            { New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -phone_number '+14155551234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept job_title alias' {
            { New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -job_title 'Manager' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require FirstName parameter' {
            { New-ZoomPhoneExternalContact -LastName 'Doe' -PhoneNumber '+14155551234' -ErrorAction Stop } | Should -Throw
        }

        It 'Should require LastName parameter' {
            { New-ZoomPhoneExternalContact -FirstName 'John' -PhoneNumber '+14155551234' -ErrorAction Stop } | Should -Throw
        }

        It 'Should require PhoneNumber parameter' {
            { New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { New-ZoomPhoneExternalContact -FirstName 'John' -LastName 'Doe' -PhoneNumber '+14155551234' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
