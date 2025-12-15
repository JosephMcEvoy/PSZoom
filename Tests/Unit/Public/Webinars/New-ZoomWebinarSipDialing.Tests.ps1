BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:mockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-sip-dialing-post.json" -Raw | ConvertFrom-Json
}

Describe 'New-ZoomWebinarSipDialing' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $script:mockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns SIP URI data for a webinar' {
            $result = New-ZoomWebinarSipDialing -WebinarId 1234567890
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Returns expected response properties' {
            $result = New-ZoomWebinarSipDialing -WebinarId 1234567890
            # Verify mock response structure is returned
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct API endpoint URL' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like "*webinars/1234567890/sip_dialing*"
            }
        }

        It 'Uses POST method' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Uses correct base URI' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/\d+/sip_dialing'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters['WebinarId'].Attributes.Where({ $_ -is [Parameter] }).Mandatory | Should -Be $True
        }

        It 'Accepts long type for WebinarId' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }

        It 'Does not require Passcode parameter' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters['Passcode'].Attributes.Where({ $_ -is [Parameter] }).Mandatory | Should -Contain $False
        }

        It 'Has webinar_id alias for WebinarId' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'Has Id alias for WebinarId' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters['WebinarId'].Aliases | Should -Contain 'Id'
        }
    }

    Context 'Passcode Parameter' {
        It 'Includes passcode in request body when provided' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890 -Passcode 'MyPasscode123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -like '*passcode*' -and $Body -like '*MyPasscode123*'
            }
        }

        It 'Does not include passcode when not provided' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -notlike '*passcode*' -or $Body -eq '{}'
            }
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline' {
            $result = 1234567890 | New-ZoomWebinarSipDialing
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $webinar = [PSCustomObject]@{ WebinarId = 1234567890 }
            $result = $webinar | New-ZoomWebinarSipDialing
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts Id alias from pipeline by property name' {
            $webinar = [PSCustomObject]@{ Id = 1234567890 }
            $result = $webinar | New-ZoomWebinarSipDialing
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Processes multiple webinars from pipeline' {
            $webinars = @(1234567890, 9876543210)
            $webinars | New-ZoomWebinarSipDialing
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2 -Exactly
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters.ContainsKey('WhatIf') | Should -Be $True
        }

        It 'Supports Confirm parameter' {
            (Get-Command New-ZoomWebinarSipDialing).Parameters.ContainsKey('Confirm') | Should -Be $True
        }

        It 'Does not call API when WhatIf is specified' {
            New-ZoomWebinarSipDialing -WebinarId 1234567890 -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error: Webinar not found' }
            { New-ZoomWebinarSipDialing -WebinarId 9999999999 } | Should -Throw
        }

        It 'Throws on invalid webinar ID format' {
            { New-ZoomWebinarSipDialing -WebinarId 'invalid' } | Should -Throw
        }
    }
}
