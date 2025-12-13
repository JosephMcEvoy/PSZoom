BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $mockResponsePath = "$PSScriptRoot/../../../Fixtures/MockResponses/user-webinar-post.json"
    $script:MockResponse = Get-Content -Path $mockResponsePath -Raw | ConvertFrom-Json
}

Describe 'New-ZoomUserWebinar' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Should return webinar data' {
            $result = New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test Webinar'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should call Invoke-ZoomRestMethod' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'API Endpoint Construction' {
        It 'Should construct correct URL for user webinar creation' {
            New-ZoomUserWebinar -UserId 'user123' -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'users/user123/webinars'
            }
        }

        It 'Should use POST method' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should encode special characters in UserId' {
            New-ZoomUserWebinar -UserId 'test+user@example.com' -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'users/test%2Buser%40example\.com/webinars'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Should require UserId parameter' {
            { New-ZoomUserWebinar -Topic 'Test Webinar' } | Should -Throw
        }

        It 'Should accept user_id alias for UserId' {
            New-ZoomUserWebinar -user_id 'test@example.com' -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'users/test%40example\.com/webinars'
            }
        }

        It 'Should accept start_time alias for StartTime' {
            New-ZoomUserWebinar -UserId 'test@example.com' -start_time '2025-01-15T10:00:00Z'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept host_video alias for HostVideo' {
            New-ZoomUserWebinar -UserId 'test@example.com' -host_video $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept template_id alias for TemplateId' {
            New-ZoomUserWebinar -UserId 'test@example.com' -template_id 'template123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Request Body Construction' {
        It 'Should include Topic in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'My Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"topic":\s*"My Test Webinar"'
            }
        }

        It 'Should include Type in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Type 5
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"type":\s*5'
            }
        }

        It 'Should include Duration in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Duration 60
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"duration":\s*60'
            }
        }

        It 'Should include Timezone in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Timezone 'America/New_York'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"timezone":\s*"America/New_York"'
            }
        }

        It 'Should include Password in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Password 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"password":\s*"abc123"'
            }
        }

        It 'Should include Agenda in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Agenda 'Test agenda content'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"agenda":\s*"Test agenda content"'
            }
        }

        It 'Should include ScheduleFor in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -ScheduleFor 'other@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"schedule_for":\s*"other@example\.com"'
            }
        }

        It 'Should include TemplateId in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -TemplateId 'template123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"template_id":\s*"template123"'
            }
        }

        It 'Should include IsSimulive in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -IsSimulive $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"is_simulive":\s*true'
            }
        }

        It 'Should include RecordFileId in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -RecordFileId 'file123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"record_file_id":\s*"file123"'
            }
        }
    }

    Context 'Settings Parameter Handling' {
        It 'Should include Settings hashtable in request body' {
            $settings = @{
                host_video = $true
                panelists_video = $false
            }
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Settings $settings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"settings":'
            }
        }

        It 'Should include HostVideo setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -HostVideo $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"host_video":\s*true'
            }
        }

        It 'Should include PanelistsVideo setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -PanelistsVideo $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"panelists_video":\s*true'
            }
        }

        It 'Should include ApprovalType setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -ApprovalType 1
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"approval_type":\s*1'
            }
        }

        It 'Should include RegistrationType setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -RegistrationType 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"registration_type":\s*2'
            }
        }

        It 'Should include Audio setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Audio 'both'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"audio":\s*"both"'
            }
        }

        It 'Should include AutoRecording setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -AutoRecording 'cloud'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"auto_recording":\s*"cloud"'
            }
        }

        It 'Should include AlternativeHosts setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -AlternativeHosts 'alt1@example.com,alt2@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"alternative_hosts":\s*"alt1@example\.com,alt2@example\.com"'
            }
        }

        It 'Should include CloseRegistration setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -CloseRegistration $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"close_registration":\s*true'
            }
        }

        It 'Should include ContactName setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -ContactName 'John Doe'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"contact_name":\s*"John Doe"'
            }
        }

        It 'Should include ContactEmail setting in request body' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -ContactEmail 'contact@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"contact_email":\s*"contact@example\.com"'
            }
        }
    }

    Context 'Pipeline Support' {
        It 'Should accept UserId from pipeline by value' {
            'test@example.com' | New-ZoomUserWebinar -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'users/test%40example\.com/webinars'
            }
        }

        It 'Should accept UserId from pipeline by property name' {
            [PSCustomObject]@{ UserId = 'pipeline@example.com' } | New-ZoomUserWebinar -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'users/pipeline%40example\.com/webinars'
            }
        }

        It 'Should accept user_id alias from pipeline by property name' {
            [PSCustomObject]@{ user_id = 'alias@example.com' } | New-ZoomUserWebinar -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'users/alias%40example\.com/webinars'
            }
        }

        It 'Should process multiple users from pipeline' {
            @('user1@example.com', 'user2@example.com') | New-ZoomUserWebinar -Topic 'Test Webinar'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Recurrence and TrackingFields Parameters' {
        It 'Should include Recurrence hashtable in request body' {
            $recurrence = @{
                type = 1
                repeat_interval = 1
            }
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -Recurrence $recurrence
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"recurrence":'
            }
        }

        It 'Should include TrackingFields array in request body' {
            $trackingFields = @(
                @{ field = 'Department'; value = 'Sales' }
            )
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' -TrackingFields $trackingFields
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"tracking_fields":'
            }
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Bad Request'
            }
        }

        It 'Should throw on API error' {
            { New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test' } | Should -Throw
        }
    }

    Context 'ShouldProcess Support' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockResponse
            }
        }

        It 'Should support WhatIf' {
            New-ZoomUserWebinar -UserId 'test@example.com' -Topic 'Test Webinar' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }
}
