BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'zoom.us'
    $script:mockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-panelist-post.json" -Raw | ConvertFrom-Json
}

Describe 'New-ZoomWebinarPanelist' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $script:mockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns panelist data when adding a single panelist' {
            $result = New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns panelist data when adding multiple panelists' {
            $panelists = @(
                @{ name = 'John Doe'; email = 'john@company.com' },
                @{ name = 'Jane Smith'; email = 'jane@company.com' }
            )
            $result = New-ZoomWebinarPanelist -WebinarId 123456789 -Panelists $panelists
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs the correct API endpoint URL' {
            New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/panelists'
            }
        }

        It 'Uses POST method' {
            New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Includes panelist data in request body for single panelist' {
            New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.panelists[0].name -eq 'John Doe' -and $bodyObj.panelists[0].email -eq 'john@company.com'
            }
        }

        It 'Includes virtual_background_id when specified' {
            New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com' -VirtualBackgroundId 'bg123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.panelists[0].virtual_background_id -eq 'bg123'
            }
        }

        It 'Includes multiple panelists in request body' {
            $panelists = @(
                @{ name = 'John Doe'; email = 'john@company.com' },
                @{ name = 'Jane Smith'; email = 'jane@company.com' }
            )
            New-ZoomWebinarPanelist -WebinarId 123456789 -Panelists $panelists
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.panelists.Count -eq 2
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command New-ZoomWebinarPanelist).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Requires Name parameter in Single parameter set' {
            $param = (Get-Command New-ZoomWebinarPanelist).Parameters['Name']
            $param.ParameterSets['Single'].IsMandatory | Should -Be $true
        }

        It 'Requires Email parameter in Single parameter set' {
            $param = (Get-Command New-ZoomWebinarPanelist).Parameters['Email']
            $param.ParameterSets['Single'].IsMandatory | Should -Be $true
        }

        It 'Requires Panelists parameter in Multiple parameter set' {
            $param = (Get-Command New-ZoomWebinarPanelist).Parameters['Panelists']
            $param.ParameterSets['Multiple'].IsMandatory | Should -Be $true
        }

        It 'Accepts webinar_id as alias for WebinarId' {
            (Get-Command New-ZoomWebinarPanelist).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'Accepts id as alias for WebinarId' {
            (Get-Command New-ZoomWebinarPanelist).Parameters['WebinarId'].Aliases | Should -Contain 'id'
        }

        It 'Accepts email_address as alias for Email' {
            (Get-Command New-ZoomWebinarPanelist).Parameters['Email'].Aliases | Should -Contain 'email_address'
        }

        It 'Accepts virtual_background_id as alias for VirtualBackgroundId' {
            (Get-Command New-ZoomWebinarPanelist).Parameters['VirtualBackgroundId'].Aliases | Should -Contain 'virtual_background_id'
        }

        It 'VirtualBackgroundId is optional' {
            $param = (Get-Command New-ZoomWebinarPanelist).Parameters['VirtualBackgroundId']
            $param.ParameterSets['Single'].IsMandatory | Should -Be $false
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789 }
            { $input | New-ZoomWebinarPanelist -Name 'John Doe' -Email 'john@company.com' } | Should -Not -Throw
        }

        It 'Accepts webinar_id alias from pipeline' {
            $input = [PSCustomObject]@{ webinar_id = 123456789 }
            { $input | New-ZoomWebinarPanelist -Name 'John Doe' -Email 'john@company.com' } | Should -Not -Throw
        }

        It 'Accepts Name and Email from pipeline by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789; Name = 'John Doe'; Email = 'john@company.com' }
            { $input | New-ZoomWebinarPanelist } | Should -Not -Throw
        }

        It 'Processes multiple pipeline inputs' {
            $inputs = @(
                [PSCustomObject]@{ WebinarId = 123456789; Name = 'John Doe'; Email = 'john@company.com' },
                [PSCustomObject]@{ WebinarId = 987654321; Name = 'Jane Smith'; Email = 'jane@company.com' }
            )
            $inputs | New-ZoomWebinarPanelist
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2 -Exactly
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            (Get-Command New-ZoomWebinarPanelist).Parameters.ContainsKey('WhatIf') | Should -Be $true
        }

        It 'Supports Confirm parameter' {
            (Get-Command New-ZoomWebinarPanelist).Parameters.ContainsKey('Confirm') | Should -Be $true
        }

        It 'Does not call API when WhatIf is specified' {
            New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error' }
            { New-ZoomWebinarPanelist -WebinarId 123456789 -Name 'John Doe' -Email 'john@company.com' } | Should -Throw
        }
    }
}
