BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state within module scope
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomAccountLockSettings' {
    Context 'When updating account lock settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            $settings = @{
                schedule_meeting = @{
                    host_video = $true
                    participant_video = $true
                }
            }
            Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/lock_settings*'
            }
        }

        It 'Should use PATCH method' {
            $settings = @{
                schedule_meeting = @{
                    host_video = $true
                }
            }
            Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should include settings in request body' {
            $settings = @{
                schedule_meeting = @{
                    host_video = $true
                    participant_video = $false
                }
                in_meeting = @{
                    chat = $true
                }
            }
            Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body -ne $null -and
                $Body.schedule_meeting -ne $null -and
                $Body.in_meeting -ne $null
            }
        }

        It 'Should return true when response is null (successful update)' {
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            $result = Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings
            $result | Should -BeTrue
        }

        It 'Should return response when response is not null' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'updated' }
            }
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            $result = Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings
            $result.status | Should -Be 'updated'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should support WhatIf' {
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when Confirm is bypassed' {
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings -Confirm:$false
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
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            'abc123' | Update-ZoomAccountLockSettings -Settings $settings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*abc123*'
            }
        }

        It 'Should accept pipeline input by property name (AccountId and Settings)' {
            $input = [PSCustomObject]@{
                AccountId = 'xyz789'
                Settings = @{ schedule_meeting = @{ host_video = $true } }
            }
            $input | Update-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*xyz789*'
            }
        }

        It 'Should accept pipeline input by property name (account_id alias)' {
            $input = [PSCustomObject]@{
                account_id = 'test456'
                Settings = @{ in_meeting = @{ chat = $true } }
            }
            $input | Update-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*test456*'
            }
        }

        It 'Should accept pipeline input by property name (id alias)' {
            $input = [PSCustomObject]@{
                id = 'id999'
                Settings = @{ email_notification = @{ jbh_reminder = $true } }
            }
            $input | Update-ZoomAccountLockSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*id999*'
            }
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should require AccountId parameter' {
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            { Update-ZoomAccountLockSettings -Settings $settings } | Should -Throw
        }

        It 'Should require Settings parameter' {
            { Update-ZoomAccountLockSettings -AccountId 'abc123' } | Should -Throw
        }

        It 'Should accept Settings as hashtable' {
            $settings = @{
                schedule_meeting = @{
                    host_video = $true
                }
            }
            { Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Bad Request')
            }
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            { Update-ZoomAccountLockSettings -AccountId 'abc123' -Settings $settings -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle 404 not found error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('The remote server returned an error: (404) Not Found.')
            }
            $settings = @{ schedule_meeting = @{ host_video = $true } }
            { Update-ZoomAccountLockSettings -AccountId 'invalid' -Settings $settings -ErrorAction Stop } | Should -Throw
        }
    }
}
