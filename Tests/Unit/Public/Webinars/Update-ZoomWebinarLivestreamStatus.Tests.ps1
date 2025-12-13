BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'test-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $fixtureFile = "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-livestream-status-patch.json"
    if (Test-Path $fixtureFile) {
        $script:MockResponse = Get-Content $fixtureFile -Raw | ConvertFrom-Json
    } else {
        $script:MockResponse = @{}
    }
}

Describe 'Update-ZoomWebinarLivestreamStatus' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Should return data when called with valid parameters' {
            $result = Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should call Invoke-ZoomRestMethod' {
            Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should work with stop action' {
            $result = Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'stop' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API Endpoint Construction' {
        It 'Should call the correct endpoint' {
            Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/livestream/status'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'PATCH'
            }
        }

        It 'Should include action in request body' {
            Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"action"\s*:\s*"start"'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Should have WebinarId as mandatory parameter' {
            (Get-Command Update-ZoomWebinarLivestreamStatus).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should accept webinar_id alias' {
            $result = Update-ZoomWebinarLivestreamStatus -webinar_id 123456789 -Action 'start' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept Id alias' {
            $result = Update-ZoomWebinarLivestreamStatus -Id 123456789 -Action 'start' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should validate Action parameter accepts start' {
            { Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should validate Action parameter accepts stop' {
            { Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'stop' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject invalid Action values' {
            { Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'invalid' -Confirm:$false } | Should -Throw
        }

        It 'Should accept Settings parameter as hashtable' {
            $settings = @{ active_speaker_name = $true }
            $result = Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Settings $settings -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Pipeline Support' {
        It 'Should accept pipeline input by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789 }
            $result = $input | Update-ZoomWebinarLivestreamStatus -Action 'start' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept pipeline input using alias' {
            $input = [PSCustomObject]@{ webinar_id = 123456789 }
            $result = $input | Update-ZoomWebinarLivestreamStatus -Action 'start' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should process multiple items from pipeline' {
            $inputs = @(
                [PSCustomObject]@{ WebinarId = 111111111 },
                [PSCustomObject]@{ WebinarId = 222222222 }
            )
            $inputs | Update-ZoomWebinarLivestreamStatus -Action 'start' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Settings Parameter' {
        It 'Should include settings in request body when provided' {
            $settings = @{ active_speaker_name = $true }
            Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Settings $settings -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"settings"'
            }
        }
    }

    Context 'SupportsShouldProcess' {
        It 'Should have SupportsShouldProcess attribute' {
            $cmdletInfo = Get-Command Update-ZoomWebinarLivestreamStatus
            $cmdletInfo.Definition | Should -Match 'SupportsShouldProcess'
        }

        It 'Should respect WhatIf parameter' {
            Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error'
            }
        }

        It 'Should throw when API returns error' {
            { Update-ZoomWebinarLivestreamStatus -WebinarId 123456789 -Action 'start' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
