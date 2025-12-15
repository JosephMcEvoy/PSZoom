BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneCallLogDetails' {
    Context 'When retrieving call log details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'log123'
                    caller = '+12345678901'
                    callee = '+19876543210'
                    duration = 120
                    call_type = 'outbound'
                    recording_url = 'https://example.com/recording'
                }
            }
        }

        It 'Should return call log details' {
            $result = Get-ZoomPhoneCallLogDetails -CallLogId 'log123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return correct call log ID' {
            $result = Get-ZoomPhoneCallLogDetails -CallLogId 'log123'
            $result.id | Should -Be 'log123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.AbsoluteUri | Should -Match 'https://api.zoom.us/v2/phone/call_logs/log123'
                return @{ id = 'log123' }
            }

            Get-ZoomPhoneCallLogDetails -CallLogId 'log123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'log123' }
            }

            Get-ZoomPhoneCallLogDetails -CallLogId 'log123'
        }
    }

    Context 'When processing multiple call logs' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $id = $Uri.AbsolutePath -replace '.*/call_logs/', ''
                return @{ id = $id }
            }
        }

        It 'Should process multiple call log IDs' {
            $result = Get-ZoomPhoneCallLogDetails -CallLogId 'log123', 'log456'
            $result.Count | Should -Be 2
        }

        It 'Should call API for each call log ID' {
            Get-ZoomPhoneCallLogDetails -CallLogId 'log1', 'log2', 'log3'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should return correct IDs for each call log' {
            $result = Get-ZoomPhoneCallLogDetails -CallLogId 'log123', 'log456'
            $result[0].id | Should -Be 'log123'
            $result[1].id | Should -Be 'log456'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'log123' }
            }
        }

        It 'Should accept CallLogId from pipeline' {
            { 'log123' | Get-ZoomPhoneCallLogDetails } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $logObject = [PSCustomObject]@{ id = 'log123' }
            { $logObject | Get-ZoomPhoneCallLogDetails } | Should -Not -Throw
        }

        It 'Should accept object with call_log_id property from pipeline' {
            $logObject = [PSCustomObject]@{ call_log_id = 'log123' }
            { $logObject | Get-ZoomPhoneCallLogDetails } | Should -Not -Throw
        }

        It 'Should process multiple objects from pipeline' {
            $logs = @(
                [PSCustomObject]@{ id = 'log123' }
                [PSCustomObject]@{ id = 'log456' }
            )
            $result = $logs | Get-ZoomPhoneCallLogDetails
            $result.Count | Should -Be 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'log123' }
            }
        }

        It 'Should accept id alias for CallLogId' {
            { Get-ZoomPhoneCallLogDetails -id 'log123' } | Should -Not -Throw
        }

        It 'Should accept call_log_id alias for CallLogId' {
            { Get-ZoomPhoneCallLogDetails -call_log_id 'log123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call log not found')
            }

            { Get-ZoomPhoneCallLogDetails -CallLogId 'invalid-log' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Get-ZoomPhoneCallLogDetails -CallLogId 'log123' -ErrorAction Stop } | Should -Throw
        }
    }
}
