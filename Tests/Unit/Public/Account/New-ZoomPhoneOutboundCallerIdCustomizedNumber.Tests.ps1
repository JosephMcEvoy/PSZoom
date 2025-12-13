BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $mockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/phone-outbound-caller-id-customized-number-post.json" -Raw | ConvertFrom-Json
}

Describe 'New-ZoomPhoneOutboundCallerIdCustomizedNumber' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $mockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns data when called with valid phone number ID' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns data when called with multiple phone number IDs' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds @('abc123def456', 'ghi789jkl012')
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once for single ID' {
            New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Calls Invoke-ZoomRestMethod exactly once for multiple IDs' {
            New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds @('abc123def456', 'ghi789jkl012')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs the correct API endpoint' {
            New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'https://api\.zoom\.us/v2/phone/outbound_caller_id/customized_numbers'
            }
        }

        It 'Uses POST method' {
            New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Includes phone_number_ids in the request body' {
            New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"phone_number_ids"'
            }
        }

        It 'Includes all phone number IDs in the request body for multiple IDs' {
            New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds @('abc123def456', 'ghi789jkl012')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'abc123def456' -and $Body -match 'ghi789jkl012'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Throws when PhoneNumberIds is not provided' {
            { New-ZoomPhoneOutboundCallerIdCustomizedNumber } | Should -Throw
        }

        It 'Accepts PhoneNumberIds as positional parameter' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber 'abc123def456'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts phone_number_ids alias' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -phone_number_ids 'abc123def456'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts PhoneNumberId alias' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberId 'abc123def456'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts Ids alias' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -Ids 'abc123def456'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts Id alias' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -Id 'abc123def456'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts single value from pipeline' {
            $result = 'abc123def456' | New-ZoomPhoneOutboundCallerIdCustomizedNumber
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts multiple values from pipeline' {
            $result = @('abc123def456', 'ghi789jkl012') | New-ZoomPhoneOutboundCallerIdCustomizedNumber
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod once when multiple values piped' {
            @('abc123def456', 'ghi789jkl012') | New-ZoomPhoneOutboundCallerIdCustomizedNumber
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Aggregates all pipeline values into single request' {
            @('id1', 'id2', 'id3') | New-ZoomPhoneOutboundCallerIdCustomizedNumber
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'id1' -and $Body -match 'id2' -and $Body -match 'id3'
            }
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            $result = New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Supports Confirm parameter' {
            (Get-Command New-ZoomPhoneOutboundCallerIdCustomizedNumber).Parameters.ContainsKey('Confirm') | Should -BeTrue
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error' }
        }

        It 'Throws when API returns an error' {
            { New-ZoomPhoneOutboundCallerIdCustomizedNumber -PhoneNumberIds 'abc123def456' } | Should -Throw 'API Error'
        }
    }
}
