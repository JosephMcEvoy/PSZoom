BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Send-ZoomPhoneSMS' {
    Context 'When sending SMS to a single recipient' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'sms123'
                    status = 'sent'
                }
            }
        }

        It 'Should send SMS with required parameters' {
            $result = Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.status | Should -Be 'sent'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/sms'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false
        }

        It 'Should include user_id in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_id | Should -Be 'user@example.com'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false
        }

        It 'Should include message in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.message | Should -Be 'Hello World'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello World' -ToPhoneNumber '+14155551234' -Confirm:$false
        }

        It 'Should include to_phone_numbers array in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.to_phone_numbers.Count | Should -Be 1
                $bodyObj.to_phone_numbers[0] | Should -Be '+14155551234'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false
        }
    }

    Context 'When sending SMS to multiple recipients' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'sms123' }
            }
        }

        It 'Should send SMS to multiple recipients' {
            $result = Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumbers @('+14155551234', '+14155555678') -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should include all phone numbers in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.to_phone_numbers.Count | Should -Be 2
                $bodyObj.to_phone_numbers[0] | Should -Be '+14155551234'
                $bodyObj.to_phone_numbers[1] | Should -Be '+14155555678'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumbers @('+14155551234', '+14155555678') -Confirm:$false
        }
    }

    Context 'When specifying from phone number' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'sms123' }
            }
        }

        It 'Should include from_phone_number when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.from_phone_number | Should -Be '+14155559999'
                return @{ id = 'sms123' }
            }

            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -FromPhoneNumber '+14155559999' -Confirm:$false
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'sms123' }
            }
        }

        It 'Should support WhatIf' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'sms123' }
            }
        }

        It 'Should accept user_id alias for UserId' {
            { Send-ZoomPhoneSMS -user_id 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept email alias for UserId' {
            { Send-ZoomPhoneSMS -email 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept to_phone_number alias' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -to_phone_number '+14155551234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept to_phone_numbers alias' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -to_phone_numbers @('+14155551234') -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept from_phone_number alias' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -from_phone_number '+14155559999' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter sets' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'sms123' }
            }
        }

        It 'Should not allow both ToPhoneNumber and ToPhoneNumbers parameters' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -ToPhoneNumbers @('+14155555678') -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should require either ToPhoneNumber or ToPhoneNumbers parameter' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require UserId parameter' {
            { Send-ZoomPhoneSMS -Message 'Hello' -ToPhoneNumber '+14155551234' -ErrorAction Stop } | Should -Throw
        }

        It 'Should require Message parameter' {
            { Send-ZoomPhoneSMS -UserId 'user@example.com' -ToPhoneNumber '+14155551234' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('SMS send failed')
            }

            { Send-ZoomPhoneSMS -UserId 'user@example.com' -Message 'Hello' -ToPhoneNumber '+14155551234' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
