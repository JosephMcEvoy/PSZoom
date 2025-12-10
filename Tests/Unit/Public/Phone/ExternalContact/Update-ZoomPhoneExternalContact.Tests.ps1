BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomPhoneExternalContact' {
    Context 'When updating an external contact' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should update with FirstName parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.first_name | Should -Be 'Jane'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/external_contacts/contact123'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -Confirm:$false
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -Confirm:$false
        }
    }

    Context 'When updating different properties' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should update last_name' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.last_name | Should -Be 'Smith'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -LastName 'Smith' -Confirm:$false
        }

        It 'Should update phone_number' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.phone_number | Should -Be '+14155559999'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -PhoneNumber '+14155559999' -Confirm:$false
        }

        It 'Should update email' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.email | Should -Be 'newemail@example.com'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -Email 'newemail@example.com' -Confirm:$false
        }

        It 'Should update company' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.company | Should -Be 'New Company'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -Company 'New Company' -Confirm:$false
        }

        It 'Should update job_title' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.job_title | Should -Be 'Director'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -JobTitle 'Director' -Confirm:$false
        }

        It 'Should update multiple properties' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.first_name | Should -Be 'Jane'
                $bodyObj.last_name | Should -Be 'Smith'
                return @{}
            }

            Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -LastName 'Smith' -Confirm:$false
        }
    }

    Context 'PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should return ContactId when PassThru is specified' {
            $result = Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -PassThru -Confirm:$false
            $result | Should -Be 'contact123'
        }

        It 'Should not return API response when PassThru is specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'contact123'; first_name = 'Jane' }
            }

            $result = Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -PassThru -Confirm:$false
            $result | Should -Be 'contact123'
            $result | Should -Not -BeOfType [hashtable]
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept ContactId from pipeline' {
            { 'contact123' | Update-ZoomPhoneExternalContact -FirstName 'Jane' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object from pipeline' {
            $contactObject = [PSCustomObject]@{
                id = 'contact123'
                FirstName = 'Jane'
            }
            { $contactObject | Update-ZoomPhoneExternalContact -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept contactId alias' {
            { Update-ZoomPhoneExternalContact -contactId 'contact123' -FirstName 'Jane' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept first_name alias' {
            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -first_name 'Jane' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept last_name alias' {
            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -last_name 'Smith' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept phone_number alias' {
            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -phone_number '+14155559999' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept job_title alias' {
            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -job_title 'Director' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require ContactId parameter' {
            { Update-ZoomPhoneExternalContact -FirstName 'Jane' -ErrorAction Stop } | Should -Throw
        }

        It 'Should throw error when no changes are provided' {
            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { Update-ZoomPhoneExternalContact -ContactId 'contact123' -FirstName 'Jane' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
