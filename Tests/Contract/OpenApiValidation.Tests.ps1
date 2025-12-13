BeforeAll {
    $ModulePath = "$PSScriptRoot/../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Load endpoint data
    $EndpointsPath = "$PSScriptRoot/../../data/zoom-api-endpoints.json"
    $CoveragePath = "$PSScriptRoot/../../data/pszoom-coverage.json"

    $script:Endpoints = @()
    $script:Coverage = @()

    if (Test-Path $EndpointsPath) {
        $script:Endpoints = (Get-Content $EndpointsPath -Raw | ConvertFrom-Json).endpoints
    }

    if (Test-Path $CoveragePath) {
        $script:Coverage = (Get-Content $CoveragePath -Raw | ConvertFrom-Json).cmdlets
    }
}

Describe 'OpenAPI Contract Validation' {

    Context 'Endpoint Coverage' {
        It 'Has endpoint data loaded' {
            $script:Endpoints | Should -Not -BeNullOrEmpty
        }

        It 'Has coverage data loaded' {
            $script:Coverage | Should -Not -BeNullOrEmpty
        }

        It 'Coverage data includes endpoint information for most cmdlets' {
            # Get cmdlets with endpoints
            $cmdletsWithEndpoints = $script:Coverage | Where-Object { $_.endpoints.Count -gt 0 }

            # Verify that cmdlets with endpoints have proper structure
            $cmdletsWithEndpoints | ForEach-Object {
                $_.endpoints | Should -Not -BeNullOrEmpty -Because "Cmdlet $($_.name) should have endpoint array"
                $_.endpoints | ForEach-Object {
                    $_.path | Should -Not -BeNullOrEmpty -Because "Endpoint should have path"
                    $_.method | Should -Not -BeNullOrEmpty -Because "Endpoint should have HTTP method"
                }
            }
        }
    }

    Context 'Cmdlet Naming Conventions' {
        It 'All cmdlets use approved PowerShell verbs' {
            $approvedVerbs = (Get-Verb).Verb

            foreach ($cmdlet in $script:Coverage) {
                $verb = ($cmdlet.name -split '-')[0]
                $verb | Should -BeIn $approvedVerbs -Because "Cmdlet $($cmdlet.name) should use approved verb"
            }
        }

        It 'All cmdlets include Zoom or PSZoom in the noun (with OAuth exception)' {
            # Allow PSZoom for module-level cmdlets like Connect-PSZoom
            # Allow OAuthToken for authentication utilities
            foreach ($cmdlet in $script:Coverage) {
                $noun = ($cmdlet.name -split '-', 2)[1]
                $noun | Should -Match '^(Zoom|PSZoom|OAuthToken)' -Because "Cmdlet $($cmdlet.name) should have Zoom, PSZoom, or OAuthToken in noun"
            }
        }
    }

    Context 'HTTP Method Mapping' {
        It 'GET endpoints map to Get-* or Test-* cmdlets' {
            # Get cmdlets with GET endpoints
            # Allow Test- for validation endpoints like Test-ZoomUserEmail
            $getCmdlets = $script:Coverage | Where-Object {
                $_.endpoints | Where-Object { $_.method -eq 'GET' }
            }

            foreach ($cmdlet in $getCmdlets) {
                $cmdlet.name | Should -Match '^(Get|Test)-' -Because "Cmdlet with GET endpoint should use Get- or Test- verb"
            }
        }

        It 'POST endpoints map to appropriate action verbs' {
            # Get cmdlets with POST endpoints
            # Allow various verbs:
            # - New/Add for creation
            # - Send/Register for submission
            # - Invoke for action execution
            # - Connect/Disconnect for session management
            # - Remove for POST-based deletion (some APIs use POST instead of DELETE)
            # - Restart/Stop for lifecycle operations
            # - Update for file uploads (POST used for multipart/form-data)
            $postCmdlets = $script:Coverage | Where-Object {
                $_.endpoints | Where-Object { $_.method -eq 'POST' }
            }

            foreach ($cmdlet in $postCmdlets) {
                $cmdlet.name | Should -Match '^(New|Add|Send|Register|Invoke|Connect|Disconnect|Remove|Restart|Stop|Update)-' -Because "Cmdlet with POST endpoint should use appropriate action verb: $($cmdlet.name)"
            }
        }

        It 'DELETE endpoints map to Remove-* or Revoke-* cmdlets' {
            # Get cmdlets with DELETE endpoints
            # Allow Revoke- for security-related deletions like SSO token revocation
            $deleteCmdlets = $script:Coverage | Where-Object {
                $_.endpoints | Where-Object { $_.method -eq 'DELETE' }
            }

            foreach ($cmdlet in $deleteCmdlets) {
                $cmdlet.name | Should -Match '^(Remove|Revoke)-' -Because "Cmdlet with DELETE endpoint should use Remove- or Revoke- verb"
            }
        }

        It 'PUT/PATCH endpoints map to Set-*, Update-*, Show-*, or Hide-* cmdlets' {
            # Get cmdlets with PUT/PATCH endpoints
            # Allow Show-/Hide- for visibility toggle endpoints
            $updateCmdlets = $script:Coverage | Where-Object {
                $_.endpoints | Where-Object { $_.method -in @('PUT', 'PATCH') }
            }

            foreach ($cmdlet in $updateCmdlets) {
                $cmdlet.name | Should -Match '^(Set|Update|Show|Hide)-' -Because "Cmdlet with PUT/PATCH endpoint should use Set/Update/Show/Hide verb"
            }
        }
    }
}

Describe 'Mock Response Fixture Validation' {
    BeforeAll {
        $FixturePath = "$PSScriptRoot/../Fixtures/MockResponses"
        $script:Fixtures = Get-ChildItem -Path $FixturePath -Filter '*.json' -ErrorAction SilentlyContinue
    }

    Context 'Fixture Files' {
        It 'Has mock response fixtures' {
            $script:Fixtures | Should -Not -BeNullOrEmpty
        }

        It 'All fixtures are valid JSON' {
            foreach ($fixture in $script:Fixtures) {
                { Get-Content $fixture.FullName -Raw | ConvertFrom-Json } | Should -Not -Throw -Because "$($fixture.Name) should be valid JSON"
            }
        }
    }
}
