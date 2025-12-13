BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:ZoomToken = 'mock-token'
    $script:ZoomURI = 'zoom.us'
    $script:MockResponse = Get-Content -Path "$PSScriptRoot/../../../Fixtures/MockResponses/user-webinar-template-post.json" -Raw | ConvertFrom-Json
}

Describe 'New-ZoomUserWebinarTemplate' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns webinar template data' {
            $result = New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs the correct URI with email' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/users/jsmith@example.com/webinar_templates'
            }
        }

        It 'Constructs the correct URI with me value' {
            New-ZoomUserWebinarTemplate -UserId 'me' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/users/me/webinar_templates'
            }
        }

        It 'Uses POST method' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }
    }

    Context 'Request Body Construction' {
        It 'Includes webinar_id in the request body' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '999888777' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -ne $null -and ($Body | ConvertFrom-Json).webinar_id -eq '999888777'
            }
        }

        It 'Includes name in the request body' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'Test Template Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -ne $null -and ($Body | ConvertFrom-Json).name -eq 'Test Template Name'
            }
        }

        It 'Includes save_recurrence when specified as true' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template' -SaveRecurrence $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -ne $null -and ($Body | ConvertFrom-Json).save_recurrence -eq $true
            }
        }

        It 'Includes save_recurrence when specified as false' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template' -SaveRecurrence $false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -ne $null -and ($Body | ConvertFrom-Json).save_recurrence -eq $false
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires UserId parameter' {
            { New-ZoomUserWebinarTemplate -WebinarId '123456789' -Name 'My Template' } | Should -Throw
        }

        It 'Requires WebinarId parameter' {
            { New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -Name 'My Template' } | Should -Throw
        }

        It 'Requires Name parameter' {
            { New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' } | Should -Throw
        }

        It 'Accepts user_id alias for UserId' {
            New-ZoomUserWebinarTemplate -user_id 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts id alias for UserId' {
            New-ZoomUserWebinarTemplate -id 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts Email alias for UserId' {
            New-ZoomUserWebinarTemplate -Email 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts webinar_id alias for WebinarId' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -webinar_id '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts save_recurrence alias for SaveRecurrence' {
            New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template' -save_recurrence $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Rejects empty Name parameter' {
            { New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name '' } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts UserId from pipeline by value' {
            'jsmith@example.com' | New-ZoomUserWebinarTemplate -WebinarId '123456789' -Name 'My Template'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts pipeline input by property name' {
            $pipelineInput = [PSCustomObject]@{
                UserId    = 'jsmith@example.com'
                WebinarId = '123456789'
                Name      = 'Pipeline Template'
            }
            $pipelineInput | New-ZoomUserWebinarTemplate
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/users/jsmith@example.com/webinar_templates'
            }
        }

        It 'Processes multiple pipeline objects' {
            $users = @(
                [PSCustomObject]@{ UserId = 'user1@example.com'; WebinarId = '111111111'; Name = 'Template 1' }
                [PSCustomObject]@{ UserId = 'user2@example.com'; WebinarId = '222222222'; Name = 'Template 2' }
            )
            $users | New-ZoomUserWebinarTemplate
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2 -Exactly
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            $result = New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0 -Exactly
        }

        It 'Supports Confirm parameter' {
            $result = New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns an error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error' }
            { New-ZoomUserWebinarTemplate -UserId 'jsmith@example.com' -WebinarId '123456789' -Name 'My Template' } | Should -Throw
        }
    }
}
