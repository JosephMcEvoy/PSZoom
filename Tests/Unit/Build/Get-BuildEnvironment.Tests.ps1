BeforeAll {
    $script:BuildPrivatePath = Join-Path $PSScriptRoot '../../../Build/Private'
    . (Join-Path $BuildPrivatePath 'Get-BuildEnvironment.ps1')
}

Describe 'Get-BuildEnvironment' {
    Context 'When running locally' {
        BeforeAll {
            $env:APPVEYOR = $null
            $env:GITHUB_ACTIONS = $null
            $script:Result = Get-BuildEnvironment -ProjectRoot $PSScriptRoot
        }

        It 'Should detect Unknown build system' {
            $Result.BuildSystem | Should -Be 'Unknown'
        }

        It 'Should set ProjectPath' {
            $Result.ProjectPath | Should -Not -BeNullOrEmpty
        }

        It 'Should set ModulePath' {
            $Result.ModulePath | Should -Match 'PSZoom$'
        }

        It 'Should populate BranchName from git' {
            $Result.BranchName | Should -Not -BeNullOrEmpty
        }

        It 'Should populate CommitMessage from git' {
            $Result.CommitMessage | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When running in AppVeyor' {
        BeforeAll {
            $env:APPVEYOR = 'True'
            $env:APPVEYOR_BUILD_FOLDER = 'C:\projects\pszoom'
            $env:APPVEYOR_REPO_COMMIT_MESSAGE = 'test commit !deploy'
            $env:APPVEYOR_REPO_BRANCH = 'master'
            $script:Result = Get-BuildEnvironment
        }

        AfterAll {
            $env:APPVEYOR = $null
            $env:APPVEYOR_BUILD_FOLDER = $null
            $env:APPVEYOR_REPO_COMMIT_MESSAGE = $null
            $env:APPVEYOR_REPO_BRANCH = $null
        }

        It 'Should detect AppVeyor build system' {
            $Result.BuildSystem | Should -Be 'AppVeyor'
        }

        It 'Should capture commit message' {
            $Result.CommitMessage | Should -Be 'test commit !deploy'
        }

        It 'Should capture branch name' {
            $Result.BranchName | Should -Be 'master'
        }
    }

    Context 'When running in GitHub Actions' {
        BeforeAll {
            $env:GITHUB_ACTIONS = 'true'
            $env:GITHUB_WORKSPACE = '/home/runner/work/PSZoom/PSZoom'
            $env:GITHUB_REF_NAME = 'main'
            $script:Result = Get-BuildEnvironment
        }

        AfterAll {
            $env:GITHUB_ACTIONS = $null
            $env:GITHUB_WORKSPACE = $null
            $env:GITHUB_REF_NAME = $null
        }

        It 'Should detect GitHub Actions build system' {
            $Result.BuildSystem | Should -Be 'GitHubActions'
        }

        It 'Should capture branch name' {
            $Result.BranchName | Should -Be 'main'
        }

        It 'Should populate CommitMessage from git' {
            $Result.CommitMessage | Should -Not -BeNullOrEmpty
        }
    }
}
