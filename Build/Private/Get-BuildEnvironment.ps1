function Get-BuildEnvironment {
    <#
    .SYNOPSIS
        Detects the build environment and returns configuration.
    .DESCRIPTION
        Replaces BuildHelpers Set-BuildEnvironment. Detects CI system
        and returns a hashtable with build configuration.
    .PARAMETER ProjectRoot
        Root path of the project. Auto-detected if not specified.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string]$ProjectRoot
    )

    # Detect build system
    $buildSystem = 'Unknown'
    $commitMessage = ''
    $branchName = ''

    if ($env:APPVEYOR -eq 'True') {
        $buildSystem = 'AppVeyor'
        $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
        $commitMessage = $env:APPVEYOR_REPO_COMMIT_MESSAGE
        $branchName = $env:APPVEYOR_REPO_BRANCH
    }
    elseif ($env:GITHUB_ACTIONS -eq 'true') {
        $buildSystem = 'GitHubActions'
        $ProjectRoot = $env:GITHUB_WORKSPACE
        $branchName = $env:GITHUB_REF_NAME
        # GitHub Actions: get commit message from git
        try {
            $commitMessage = git log -1 --pretty=%B 2>$null
        } catch {
            $commitMessage = ''
        }
    }
    else {
        # Local build - detect project root
        if (-not $ProjectRoot) {
            $ProjectRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
        }
        # Get git info if available
        try {
            Push-Location $ProjectRoot
            $branchName = git rev-parse --abbrev-ref HEAD 2>$null
            $commitMessage = git log -1 --pretty=%B 2>$null
            Pop-Location
        } catch {
            $branchName = 'unknown'
            $commitMessage = ''
        }
    }

    # Normalize project root
    if (-not $ProjectRoot) {
        $ProjectRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
    }

    # Find module path and manifest
    $moduleName = 'PSZoom'
    $modulePath = Join-Path $ProjectRoot $moduleName
    $manifestPath = Join-Path $modulePath "$moduleName.psd1"

    @{
        BuildSystem    = $buildSystem
        ProjectPath    = $ProjectRoot
        ProjectName    = $moduleName
        ModulePath     = $modulePath
        PSModuleManifest = $manifestPath
        CommitMessage  = $commitMessage
        BranchName     = $branchName
    }
}
