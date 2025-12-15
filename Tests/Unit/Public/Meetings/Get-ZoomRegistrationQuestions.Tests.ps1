BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomRegistrationQuestions' {
    Context 'When retrieving registration questions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ questions = @(@{ field_name = 'first_name'; required = $true }) }
            }
        }

        It 'Should return registration questions' {
            $result = Get-ZoomRegistrationQuestions -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return questions array' {
            $result = Get-ZoomRegistrationQuestions -MeetingId '1234567890'
            $result.questions | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct registrants/questions endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/registrants/questions'
                return @{ questions = @() }
            }

            Get-ZoomRegistrationQuestions -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ questions = @() }
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomRegistrationQuestions
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomRegistrationQuestions } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomRegistrationQuestions -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
