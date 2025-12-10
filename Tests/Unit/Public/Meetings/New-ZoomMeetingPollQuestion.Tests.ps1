BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomMeetingPollQuestion' {
    Context 'When creating a poll question object' {
        It 'Should return a question hashtable' {
            $result = New-ZoomMeetingPollQuestion -Name 'Test Question?' -Type 'single' -Answers @('Yes', 'No')
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [Hashtable]
        }

        It 'Should return question with name property' {
            $result = New-ZoomMeetingPollQuestion -Name 'Test Question?' -Type 'single' -Answers @('Yes', 'No')
            $result.name | Should -Be 'Test Question?'
        }

        It 'Should return question with type property' {
            $result = New-ZoomMeetingPollQuestion -Name 'Test Question?' -Type 'single' -Answers @('Yes', 'No')
            $result.type | Should -Be 'single'
        }

        It 'Should return question with answers property' {
            $result = New-ZoomMeetingPollQuestion -Name 'Test Question?' -Type 'single' -Answers @('Yes', 'No')
            $result.answers | Should -Contain 'Yes'
            $result.answers | Should -Contain 'No'
        }
    }

    Context 'Type parameter validation' {
        It 'Should accept single type' {
            { New-ZoomMeetingPollQuestion -Name 'Q?' -Type 'single' -Answers @('A', 'B') } | Should -Not -Throw
        }

        It 'Should accept multiple type' {
            { New-ZoomMeetingPollQuestion -Name 'Q?' -Type 'multiple' -Answers @('A', 'B') } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require Name parameter' {
            { New-ZoomMeetingPollQuestion -Type 'single' -Answers @('A', 'B') } | Should -Throw
        }

        It 'Should require Type parameter' {
            { New-ZoomMeetingPollQuestion -Name 'Q?' -Answers @('A', 'B') } | Should -Throw
        }

        It 'Should require Answers parameter' {
            { New-ZoomMeetingPollQuestion -Name 'Q?' -Type 'single' } | Should -Throw
        }
    }

    Context 'Usage with New-ZoomMeetingPoll' {
        It 'Should create objects usable by New-ZoomMeetingPoll' {
            $question = New-ZoomMeetingPollQuestion -Name 'Favorite color?' -Type 'multiple' -Answers @('Red', 'Blue', 'Green')
            $question.Keys | Should -Contain 'name'
            $question.Keys | Should -Contain 'type'
            $question.Keys | Should -Contain 'answers'
        }
    }
}
