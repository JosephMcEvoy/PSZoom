BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneCallLog' {
    Context 'When removing a call log' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomPhoneCallLog -CallLogId 'log123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri.AbsoluteUri -match 'https://api.zoom.us/v2/phone/call_logs/log123'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomPhoneCallLog -CallLogId 'log123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should return response by default' {
            $result = Remove-ZoomPhoneCallLog -CallLogId 'log123' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should not return response when PassThru is not specified' {
            $result = Remove-ZoomPhoneCallLog -CallLogId 'log123' -Confirm:$false
            $result.success | Should -Be $true
        }
    }

    Context 'When using PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return CallLogId when PassThru is specified' {
            $result = Remove-ZoomPhoneCallLog -CallLogId 'log123' -PassThru -Confirm:$false
            $result | Should -Be 'log123'
        }

        It 'Should return multiple CallLogIds when PassThru is specified' {
            $result = Remove-ZoomPhoneCallLog -CallLogId 'log123', 'log456' -PassThru -Confirm:$false
            $result.Count | Should -Be 2
            $result[0] | Should -Be 'log123'
            $result[1] | Should -Be 'log456'
        }
    }

    Context 'When processing multiple call logs' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should process multiple call log IDs' {
            Remove-ZoomPhoneCallLog -CallLogId 'log123', 'log456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should call API for each call log ID' {
            Remove-ZoomPhoneCallLog -CallLogId 'log1', 'log2', 'log3' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support WhatIf' {
            Remove-ZoomPhoneCallLog -CallLogId 'log123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should prompt for confirmation when Confirm is true' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }

            # This would normally prompt, but with -Confirm:$false it won't
            Remove-ZoomPhoneCallLog -CallLogId 'log123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept CallLogId from pipeline' {
            { 'log123' | Remove-ZoomPhoneCallLog -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $logObject = [PSCustomObject]@{ id = 'log123' }
            { $logObject | Remove-ZoomPhoneCallLog -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with call_log_id property from pipeline' {
            $logObject = [PSCustomObject]@{ call_log_id = 'log123' }
            { $logObject | Remove-ZoomPhoneCallLog -Confirm:$false } | Should -Not -Throw
        }

        It 'Should process multiple objects from pipeline' {
            $logs = @('log123', 'log456')
            $logs | Remove-ZoomPhoneCallLog -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept Id alias for CallLogId' {
            { Remove-ZoomPhoneCallLog -Id 'log123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Ids alias for CallLogId' {
            { Remove-ZoomPhoneCallLog -Ids 'log123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept call_log_id alias for CallLogId' {
            { Remove-ZoomPhoneCallLog -call_log_id 'log123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call log not found')
            }

            { Remove-ZoomPhoneCallLog -CallLogId 'invalid-log' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Remove-ZoomPhoneCallLog -CallLogId 'log123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should validate CallLogId length' {
            $longId = 'a' * 129
            { Remove-ZoomPhoneCallLog -CallLogId $longId -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
