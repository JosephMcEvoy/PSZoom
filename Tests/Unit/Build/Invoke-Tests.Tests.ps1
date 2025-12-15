# Tests/Unit/Build/Invoke-Tests.Tests.ps1
BeforeAll {
    $script:ProjectRoot = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName
}

Describe 'Invoke-Tests.ps1' {
    It 'Should exist at project root' {
        Test-Path (Join-Path $ProjectRoot 'Invoke-Tests.ps1') | Should -BeTrue
    }

    It 'Should have valid PowerShell syntax' {
        $script = Get-Content (Join-Path $ProjectRoot 'Invoke-Tests.ps1') -Raw
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$null, [ref]$errors)
        $errors | Should -BeNullOrEmpty
    }

    It 'Should have -TestType parameter' {
        $command = Get-Command (Join-Path $ProjectRoot 'Invoke-Tests.ps1')
        $command.Parameters.Keys | Should -Contain 'TestType'
    }

    It 'Should have -NoCoverage parameter' {
        $command = Get-Command (Join-Path $ProjectRoot 'Invoke-Tests.ps1')
        $command.Parameters.Keys | Should -Contain 'NoCoverage'
    }
}
