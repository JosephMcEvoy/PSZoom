BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneExternalContact' {
    Context 'When removing an external contact' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should remove an external contact' {
            Remove-ZoomPhoneExternalContact -ContactId 'contact123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/external_contacts/contact123'
                return @{}
            }

            Remove-ZoomPhoneExternalContact -ContactId 'contact123' -Confirm:$false
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomPhoneExternalContact -ContactId 'contact123' -Confirm:$false
        }
    }

    Context 'When removing multiple external contacts' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should handle multiple ContactIds' {
            Remove-ZoomPhoneExternalContact -ContactId 'contact123', 'contact456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should return ContactId when PassThru is specified' {
            $result = Remove-ZoomPhoneExternalContact -ContactId 'contact123' -PassThru -Confirm:$false
            $result | Should -Be 'contact123'
        }

        It 'Should return multiple ContactIds when PassThru is specified' {
            $result = Remove-ZoomPhoneExternalContact -ContactId 'contact123', 'contact456' -PassThru -Confirm:$false
            $result.Count | Should -Be 2
            $result[0] | Should -Be 'contact123'
            $result[1] | Should -Be 'contact456'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            { Remove-ZoomPhoneExternalContact -ContactId 'contact123' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Remove-ZoomPhoneExternalContact -ContactId 'contact123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have High impact' {
            $command = Get-Command Remove-ZoomPhoneExternalContact
            $command.Parameters['Confirm'].Attributes.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept ContactId from pipeline' {
            { 'contact123' | Remove-ZoomPhoneExternalContact -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept multiple ContactIds from pipeline' {
            { 'contact123', 'contact456' | Remove-ZoomPhoneExternalContact -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $contactObject = [PSCustomObject]@{ id = 'contact123' }
            { $contactObject | Remove-ZoomPhoneExternalContact -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept contactId alias' {
            { Remove-ZoomPhoneExternalContact -contactId 'contact123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Remove-ZoomPhoneExternalContact -id 'contact123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept contact_id alias' {
            { Remove-ZoomPhoneExternalContact -contact_id 'contact123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require ContactId parameter' {
            { Remove-ZoomPhoneExternalContact -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('External contact not found')
            }

            { Remove-ZoomPhoneExternalContact -ContactId 'invalid' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
