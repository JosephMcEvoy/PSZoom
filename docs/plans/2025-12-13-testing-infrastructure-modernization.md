# Testing Infrastructure Modernization Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernize the PSZoom build and test infrastructure by removing PSDepend and BuildHelpers dependencies, creating a unified test runner, and ensuring tests work both locally and in AppVeyor CI.

**Architecture:** Replace dependency management with direct PowerShell module installation. Replace BuildHelpers environment detection with simple PowerShell logic. Create a single entry-point script (`Invoke-Tests.ps1`) that orchestrates all test types using Pester 5 and integrates with psake.

**Tech Stack:** PowerShell 5.1+/7+, Pester 5.6.1, psake 4.9.0, PSDeploy 1.0.5

---

## Summary of Changes

| Component | Current | Target |
|-----------|---------|--------|
| Dependency Management | PSDepend + build.requirements.psd1 | Direct `Install-Module` calls |
| Environment Detection | BuildHelpers `Set-BuildEnvironment` | Custom `Build/Private/Get-BuildEnvironment.ps1` |
| Module Functions | BuildHelpers `Set-ModuleFunctions` | Custom `Build/Private/Set-PSZoomModuleFunctions.ps1` |
| Test Runner | Manual Pester invocation | `Invoke-Tests.ps1` unified script |
| Legacy Tests | `Test/` folder (Pester 4) | Deleted |
| CI | AppVeyor with PSDepend | AppVeyor with direct module install |

---

## Task 1: Create Build Environment Helper

**Files:**
- Create: `Build/Private/Get-BuildEnvironment.ps1`

**Step 1: Write the failing test**

Create test file:

```powershell
# Tests/Unit/Build/Get-BuildEnvironment.Tests.ps1
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
    }
}
```

**Step 2: Run test to verify it fails**

Run: `Invoke-Pester ./Tests/Unit/Build/Get-BuildEnvironment.Tests.ps1 -Output Detailed`
Expected: FAIL with "Get-BuildEnvironment is not recognized"

**Step 3: Create directory structure**

```powershell
New-Item -ItemType Directory -Path ./Build/Private -Force
New-Item -ItemType Directory -Path ./Tests/Unit/Build -Force
```

**Step 4: Write minimal implementation**

```powershell
# Build/Private/Get-BuildEnvironment.ps1
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
```

**Step 5: Run test to verify it passes**

Run: `Invoke-Pester ./Tests/Unit/Build/Get-BuildEnvironment.Tests.ps1 -Output Detailed`
Expected: PASS

**Step 6: Commit**

```bash
git add Tests/Unit/Build/Get-BuildEnvironment.Tests.ps1 Build/Private/Get-BuildEnvironment.ps1
git commit -m "feat(build): add Get-BuildEnvironment helper to replace BuildHelpers"
```

---

## Task 2: Create Module Functions Helper

**Files:**
- Create: `Build/Private/Set-PSZoomModuleFunctions.ps1`
- Create: `Tests/Unit/Build/Set-PSZoomModuleFunctions.Tests.ps1`

**Step 1: Write the failing test**

```powershell
# Tests/Unit/Build/Set-PSZoomModuleFunctions.Tests.ps1
BeforeAll {
    $script:BuildPrivatePath = Join-Path $PSScriptRoot '../../../Build/Private'
    . (Join-Path $BuildPrivatePath 'Set-PSZoomModuleFunctions.ps1')
}

Describe 'Set-PSZoomModuleFunctions' {
    Context 'When updating module manifest' {
        BeforeAll {
            # Create a temp manifest for testing
            $script:TempDir = Join-Path $TestDrive 'TestModule'
            New-Item -ItemType Directory -Path $TempDir -Force
            New-Item -ItemType Directory -Path (Join-Path $TempDir 'Public') -Force

            # Create test functions
            @'
function Get-TestFunction1 { }
'@ | Set-Content (Join-Path $TempDir 'Public/Get-TestFunction1.ps1')

            @'
function Get-TestFunction2 { }
'@ | Set-Content (Join-Path $TempDir 'Public/Get-TestFunction2.ps1')

            # Create minimal manifest
            New-ModuleManifest -Path (Join-Path $TempDir 'TestModule.psd1') -RootModule 'TestModule.psm1' -FunctionsToExport @()
        }

        It 'Should update FunctionsToExport in manifest' {
            $manifestPath = Join-Path $TempDir 'TestModule.psd1'
            Set-PSZoomModuleFunctions -ManifestPath $manifestPath -PublicPath (Join-Path $TempDir 'Public')

            $manifest = Import-PowerShellDataFile -Path $manifestPath
            $manifest.FunctionsToExport | Should -Contain 'Get-TestFunction1'
            $manifest.FunctionsToExport | Should -Contain 'Get-TestFunction2'
        }
    }
}
```

**Step 2: Run test to verify it fails**

Run: `Invoke-Pester ./Tests/Unit/Build/Set-PSZoomModuleFunctions.Tests.ps1 -Output Detailed`
Expected: FAIL with "Set-PSZoomModuleFunctions is not recognized"

**Step 3: Write minimal implementation**

```powershell
# Build/Private/Set-PSZoomModuleFunctions.ps1
function Set-PSZoomModuleFunctions {
    <#
    .SYNOPSIS
        Updates the FunctionsToExport in a module manifest.
    .DESCRIPTION
        Scans Public folder for function files and updates the manifest.
        Replaces BuildHelpers Set-ModuleFunctions.
    .PARAMETER ManifestPath
        Path to the module manifest (.psd1) file.
    .PARAMETER PublicPath
        Path to the Public functions folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter()]
        [string]$PublicPath
    )

    if (-not $PublicPath) {
        $PublicPath = Join-Path (Split-Path $ManifestPath -Parent) 'Public'
    }

    # Get all public function names from .ps1 files
    $functions = Get-ChildItem -Path $PublicPath -Filter '*.ps1' -Recurse |
        ForEach-Object {
            $_.BaseName
        } |
        Sort-Object -Unique

    if ($functions.Count -eq 0) {
        Write-Warning "No functions found in $PublicPath"
        return
    }

    # Update manifest
    Update-ModuleManifest -Path $ManifestPath -FunctionsToExport $functions
    Write-Verbose "Updated $ManifestPath with $($functions.Count) functions"
}
```

**Step 4: Run test to verify it passes**

Run: `Invoke-Pester ./Tests/Unit/Build/Set-PSZoomModuleFunctions.Tests.ps1 -Output Detailed`
Expected: PASS

**Step 5: Commit**

```bash
git add Tests/Unit/Build/Set-PSZoomModuleFunctions.Tests.ps1 Build/Private/Set-PSZoomModuleFunctions.ps1
git commit -m "feat(build): add Set-PSZoomModuleFunctions helper to replace BuildHelpers"
```

---

## Task 3: Create Unified Test Runner Script

**Files:**
- Create: `Invoke-Tests.ps1`

**Step 1: Write the failing test**

```powershell
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
```

**Step 2: Run test to verify it fails**

Run: `Invoke-Pester ./Tests/Unit/Build/Invoke-Tests.Tests.ps1 -Output Detailed`
Expected: FAIL with "Cannot find path 'Invoke-Tests.ps1'"

**Step 3: Write implementation**

```powershell
# Invoke-Tests.ps1
<#
.SYNOPSIS
    Unified test runner for PSZoom module.

.DESCRIPTION
    Runs Pester tests for the PSZoom module. Supports unit tests, integration tests,
    contract tests, or all tests. Works both locally and in CI environments.

.PARAMETER TestType
    Type of tests to run: Unit, Integration, Contract, or All.
    Default: Unit

.PARAMETER NoCoverage
    Skip code coverage collection. Speeds up test runs.

.PARAMETER OutputPath
    Directory for test results. Default: ./Tests

.PARAMETER PassThru
    Return the Pester result object.

.EXAMPLE
    ./Invoke-Tests.ps1
    Runs unit tests with code coverage.

.EXAMPLE
    ./Invoke-Tests.ps1 -TestType All -NoCoverage
    Runs all tests without code coverage.

.EXAMPLE
    ./Invoke-Tests.ps1 -TestType Integration
    Runs integration tests (requires Zoom API credentials).
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Unit', 'Integration', 'Contract', 'All')]
    [string]$TestType = 'Unit',

    [Parameter()]
    [switch]$NoCoverage,

    [Parameter()]
    [string]$OutputPath = './Tests',

    [Parameter()]
    [switch]$PassThru
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot

# Ensure Pester 5+ is available
$pester = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version.Major -ge 5 } | Select-Object -First 1
if (-not $pester) {
    Write-Error "Pester 5+ is required. Install with: Install-Module -Name Pester -MinimumVersion 5.0.0 -Force"
    exit 1
}
Import-Module Pester -MinimumVersion 5.0.0 -Force

# Build configuration based on test type
$config = New-PesterConfiguration

$config.Output.Verbosity = 'Detailed'
$config.Output.StackTraceVerbosity = 'Filtered'
$config.Should.ErrorAction = 'Continue'
$config.Run.PassThru = $true

switch ($TestType) {
    'Unit' {
        Write-Host "`n=== Running Unit Tests ===" -ForegroundColor Cyan
        $config.Run.Path = "$ProjectRoot/Tests"
        $config.Filter.ExcludeTag = @('Integration', 'Contract')
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/testResults.xml"

        if (-not $NoCoverage) {
            $config.CodeCoverage.Enabled = $true
            $config.CodeCoverage.Path = @(
                "$ProjectRoot/PSZoom/Public/**/*.ps1"
                "$ProjectRoot/PSZoom/Private/**/*.ps1"
            )
            $config.CodeCoverage.OutputFormat = 'JaCoCo'
            $config.CodeCoverage.OutputPath = "$OutputPath/coverage.xml"
            $config.CodeCoverage.CoveragePercentTarget = 80
        }
    }
    'Integration' {
        Write-Host "`n=== Running Integration Tests ===" -ForegroundColor Cyan

        # Check for credentials
        if (-not $env:ZOOM_ACCOUNT_ID -or -not $env:ZOOM_CLIENT_ID -or -not $env:ZOOM_CLIENT_SECRET) {
            Write-Warning "Zoom API credentials not configured. Set ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, and ZOOM_CLIENT_SECRET environment variables."
            Write-Warning "Skipping integration tests."
            exit 0
        }

        $config.Run.Path = "$ProjectRoot/Tests/Integration"
        $config.Filter.Tag = @('Integration')
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/integrationTestResults.xml"
    }
    'Contract' {
        Write-Host "`n=== Running Contract Tests ===" -ForegroundColor Cyan
        $config.Run.Path = "$ProjectRoot/Tests/Contract"
        $config.Filter.Tag = @('Contract')
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/contractTestResults.xml"
    }
    'All' {
        Write-Host "`n=== Running All Tests ===" -ForegroundColor Cyan
        $config.Run.Path = "$ProjectRoot/Tests"
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputFormat = 'NUnitXml'
        $config.TestResult.OutputPath = "$OutputPath/allTestResults.xml"

        if (-not $NoCoverage) {
            $config.CodeCoverage.Enabled = $true
            $config.CodeCoverage.Path = @(
                "$ProjectRoot/PSZoom/Public/**/*.ps1"
                "$ProjectRoot/PSZoom/Private/**/*.ps1"
            )
            $config.CodeCoverage.OutputFormat = 'JaCoCo'
            $config.CodeCoverage.OutputPath = "$OutputPath/coverage.xml"
            $config.CodeCoverage.CoveragePercentTarget = 80
        }
    }
}

# Run tests
$results = Invoke-Pester -Configuration $config

# Output summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Tests Run: $($results.TotalCount)"
Write-Host "Passed: $($results.PassedCount)" -ForegroundColor Green
Write-Host "Failed: $($results.FailedCount)" -ForegroundColor $(if ($results.FailedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "Skipped: $($results.SkippedCount)" -ForegroundColor Yellow

if ($results.CodeCoverage) {
    $coverage = [math]::Round(($results.CodeCoverage.CoveragePercent), 2)
    Write-Host "Code Coverage: $coverage%" -ForegroundColor $(if ($coverage -ge 80) { 'Green' } else { 'Yellow' })
}

# Return results or exit with appropriate code
if ($PassThru) {
    return $results
}

exit $results.FailedCount
```

**Step 4: Run test to verify it passes**

Run: `Invoke-Pester ./Tests/Unit/Build/Invoke-Tests.Tests.ps1 -Output Detailed`
Expected: PASS

**Step 5: Commit**

```bash
git add Invoke-Tests.ps1 Tests/Unit/Build/Invoke-Tests.Tests.ps1
git commit -m "feat(test): add unified Invoke-Tests.ps1 test runner"
```

---

## Task 4: Update psake Build Script

**Files:**
- Modify: `Build/psake.ps1`

**Step 1: Read current file and understand changes needed**

The current psake.ps1 uses these BuildHelpers features:
- `$ENV:BHProjectPath` - project root path
- `$ENV:BHCommitMessage` - commit message
- `$ENV:BHBuildSystem` - CI system detection
- `Set-ModuleFunctions` - update manifest exports
- `Get-NextNugetPackageVersion` - version bump
- `Get-MetaData` / `Update-Metadata` - manifest manipulation
- `$env:BHPSModuleManifest` - manifest path

**Step 2: Write the updated psake.ps1**

```powershell
# Build/psake.ps1

# Load build helpers
. "$PSScriptRoot\Private\Get-BuildEnvironment.ps1"
. "$PSScriptRoot\Private\Set-PSZoomModuleFunctions.ps1"

# PSake makes variables declared here available in other scriptblocks
Properties {
    # Get build environment
    $script:BuildEnv = Get-BuildEnvironment -ProjectRoot (Resolve-Path "$PSScriptRoot\..")
    $ProjectRoot = $BuildEnv.ProjectPath
    $ModulePath = $BuildEnv.ModulePath
    $ManifestPath = $BuildEnv.PSModuleManifest
    $BuildSystem = $BuildEnv.BuildSystem
    $CommitMessage = $BuildEnv.CommitMessage
    $BranchName = $BuildEnv.BranchName

    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

    if ($CommitMessage -match "!verbose") {
        $Verbose = @{Verbose = $True}
    }
}

FormatTaskName "$('-' * (57 - {0}.length)){0}$('-' * (57 - {0}.length))"

Task Default -Depends Deploy

Task Init {
    Set-Location $ProjectRoot
    Write-Host "Build System: $BuildSystem"
    Write-Host "Project Root: $ProjectRoot"
    Write-Host "Module Path: $ModulePath"
    Write-Host "Branch: $BranchName"
} -description 'Initialize build environment'

Task Test -Depends Init {
    # Use unified test runner
    & "$ProjectRoot\Invoke-Tests.ps1" -TestType Unit -OutputPath $ProjectRoot

    # In AppVeyor? Upload our tests!
    if ($BuildSystem -eq 'AppVeyor') {
        $testResultPath = Join-Path $ProjectRoot 'Tests' 'testResults.xml'
        if (Test-Path $testResultPath) {
            (New-Object 'System.Net.WebClient').UploadFile(
                "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
                $testResultPath
            )
        }
    }
} -description 'Run tests'

Task Build -Depends Test {
    # Update module functions in manifest
    Set-PSZoomModuleFunctions -ManifestPath $ManifestPath

    # Bump version if deploying
    if ($CommitMessage -match '!deploy') {
        try {
            # Get current gallery version
            $galleryModule = Find-Module -Name 'PSZoom' -Repository PSGallery -ErrorAction SilentlyContinue
            if ($galleryModule) {
                [version]$galleryVersion = $galleryModule.Version
                $manifest = Import-PowerShellDataFile -Path $ManifestPath
                [version]$currentVersion = $manifest.ModuleVersion

                if ($galleryVersion -ge $currentVersion) {
                    # Increment patch version
                    $newVersion = [version]::new($galleryVersion.Major, $galleryVersion.Minor, $galleryVersion.Build + 1)
                    Update-ModuleManifest -Path $ManifestPath -ModuleVersion $newVersion
                    Write-Host "Updated version from $currentVersion to $newVersion"
                }
            }
        } catch {
            Write-Warning "Failed to update version: $_. Continuing with existing version."
        }
    }
} -description 'Build module and increment version'

Task Deploy -Depends Build {
    $Params = @{
        Path = $ProjectRoot
        Force = $true
        Recurse = $true
    }

    Invoke-PSDeploy @Verbose @Params
} -description 'Deploy to PowerShell Gallery'
```

**Step 3: Run tests to verify psake works**

Run: `Invoke-psake ./Build/psake.ps1 -taskList Init`
Expected: PASS - shows build environment info

**Step 4: Commit**

```bash
git add Build/psake.ps1
git commit -m "refactor(build): update psake.ps1 to use custom helpers instead of BuildHelpers"
```

---

## Task 5: Update Deploy Script

**Files:**
- Modify: `Build/deploy.psdeploy.ps1`

**Step 1: Write the updated deploy script**

```powershell
# Build/deploy.psdeploy.ps1

# Load build environment helper
. "$PSScriptRoot\Private\Get-BuildEnvironment.ps1"
$BuildEnv = Get-BuildEnvironment

# Publish to gallery with restrictions
if ($BuildEnv.ModulePath -and
    $BuildEnv.BuildSystem -ne 'Unknown' -and
    $BuildEnv.BranchName -eq "master" -and
    $BuildEnv.CommitMessage -match '!deploy'
) {
    Deploy Module {
        By PSGalleryModule {
            FromSource $BuildEnv.ModulePath
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
                SkipAutomaticTags = $True
            }
        }
    }
} else {
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $($BuildEnv.BuildSystem))`n" +
    "`t* You are committing to the master branch (Current: $($BuildEnv.BranchName)) `n" +
    "`t* Your commit message includes !deploy (Current: $($BuildEnv.CommitMessage))" |
        Write-Host
}

# Publish to AppVeyor if we're in AppVeyor
if ($BuildEnv.ModulePath -and $BuildEnv.BuildSystem -eq 'AppVeyor') {
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $BuildEnv.ModulePath
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}
```

**Step 2: Commit**

```bash
git add Build/deploy.psdeploy.ps1
git commit -m "refactor(build): update deploy script to use custom helpers"
```

---

## Task 6: Update Start-Build.ps1 (Remove PSDepend)

**Files:**
- Modify: `Build/Start-Build.ps1`

**Step 1: Write the updated Start-Build.ps1**

```powershell
# Build/Start-Build.ps1
<#
.SYNOPSIS
    Entry point for PSZoom build process.
.DESCRIPTION
    Installs required modules and invokes psake build tasks.
.PARAMETER Task
    Build task to run. Default: Default (runs all tasks)
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$Task = 'Default'
)

$ErrorActionPreference = 'Stop'

# Required modules with minimum versions
$requiredModules = @{
    'psake'    = '4.9.0'
    'PSDeploy' = '1.0.5'
    'Pester'   = '5.6.1'
}

Write-Host "=== Installing Build Dependencies ===" -ForegroundColor Cyan

foreach ($module in $requiredModules.GetEnumerator()) {
    $installed = Get-Module -Name $module.Key -ListAvailable |
        Where-Object { $_.Version -ge [version]$module.Value } |
        Select-Object -First 1

    if (-not $installed) {
        Write-Host "Installing $($module.Key) v$($module.Value)..."
        Install-Module -Name $module.Key -RequiredVersion $module.Value -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber
    } else {
        Write-Host "$($module.Key) v$($installed.Version) already installed"
    }

    Import-Module -Name $module.Key -MinimumVersion $module.Value -Force
}

Write-Host "`n=== Starting Build ===" -ForegroundColor Cyan

# Invoke psake
Invoke-psake "$PSScriptRoot\psake.ps1" -taskList $Task

exit ([int](-not $psake.build_success))
```

**Step 2: Run the build to verify it works**

Run: `.\Build\Start-Build.ps1 -Task Init`
Expected: PASS - installs modules and runs Init task

**Step 3: Commit**

```bash
git add Build/Start-Build.ps1
git commit -m "refactor(build): remove PSDepend dependency from Start-Build.ps1"
```

---

## Task 7: Update AppVeyor Configuration

**Files:**
- Modify: `AppVeyor.yml`

**Step 1: Write the updated AppVeyor.yml**

```yaml
# AppVeyor CI configuration for PSZoom

environment:
  nugetapikey:
    secure: /wkBebPoOhfZSU+7O0z+jpst5N+PDX+iD02S3z37lkDYqZ6CHixD/4xCXElBpth1

# Use Windows Server with PowerShell 7
image: Visual Studio 2022

# Skip on updates to the readme
skip_commits:
  message: /updated readme.*|update readme.*s/

# Don't use AppVeyor's automatic build
build: false

# Disable automatic test discovery
test: off

# Install dependencies (no PSDepend or BuildHelpers)
install:
  - pwsh: |
      Set-PSRepository PSGallery -InstallationPolicy Trusted
      Install-Module -Name psake -RequiredVersion 4.9.0 -Force -Scope CurrentUser
      Install-Module -Name PSDeploy -RequiredVersion 1.0.5 -Force -Scope CurrentUser
      Install-Module -Name Pester -RequiredVersion 5.6.1 -Force -Scope CurrentUser -SkipPublisherCheck

# Run the CI/CD pipeline
build_script:
  - pwsh: |
      $ErrorActionPreference = 'Stop'
      . .\Build\Start-Build.ps1 -Task Deploy

# Only build these branches
branches:
  only:
    - master
    - main
    - develop
    - dev

# Artifacts to preserve
artifacts:
  - path: '**\TestResults*.xml'
    name: TestResults
  - path: 'Tests\testResults.xml'
    name: UnitTestResults
  - path: 'Tests\coverage.xml'
    name: CoverageReport
```

**Step 2: Commit**

```bash
git add AppVeyor.yml
git commit -m "refactor(ci): remove BuildHelpers and PSDepend from AppVeyor"
```

---

## Task 8: Delete Legacy Files

**Files:**
- Delete: `Build/helpers/Install-PSDepend.ps1`
- Delete: `Build/build.requirements.psd1`
- Delete: `Test/` folder (entire directory)

**Step 1: Remove PSDepend bootstrap script**

```bash
git rm Build/helpers/Install-PSDepend.ps1
rmdir Build/helpers  # if empty
```

**Step 2: Remove build.requirements.psd1**

```bash
git rm Build/build.requirements.psd1
```

**Step 3: Remove legacy Test folder**

```bash
git rm -r Test/
```

**Step 4: Commit**

```bash
git commit -m "chore(cleanup): remove PSDepend, BuildHelpers dependencies and legacy Test folder"
```

---

## Task 9: Create Contract Test Configuration

**Files:**
- Create: `pester.contract.config.psd1`

**Step 1: Write the contract test config**

```powershell
# pester.contract.config.psd1
@{
    Run = @{
        Path = './Tests/Contract'
        Exit = $true
        PassThru = $true
    }
    Filter = @{
        Tag = @('Contract')
    }
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = './Tests/contractTestResults.xml'
    }
    Output = @{
        Verbosity = 'Detailed'
        StackTraceVerbosity = 'Filtered'
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}
```

**Step 2: Commit**

```bash
git add pester.contract.config.psd1
git commit -m "feat(test): add contract test Pester configuration"
```

---

## Task 10: Final Verification and Documentation

**Files:**
- Update: `README.md` (testing section)

**Step 1: Run full test suite locally**

```powershell
# Run unit tests
./Invoke-Tests.ps1 -TestType Unit

# Run with no coverage (faster)
./Invoke-Tests.ps1 -TestType Unit -NoCoverage

# Run all tests (if credentials available)
./Invoke-Tests.ps1 -TestType All
```

Expected: All tests pass

**Step 2: Run build pipeline locally**

```powershell
./Build/Start-Build.ps1 -Task Test
```

Expected: Build completes successfully

**Step 3: Update README testing section**

Add to README.md under a "Testing" section:

```markdown
## Testing

PSZoom uses [Pester 5](https://pester.dev/) for testing and [psake](https://psake.dev/) for build automation.

### Running Tests Locally

```powershell
# Install Pester if needed
Install-Module -Name Pester -MinimumVersion 5.6.1 -Force

# Run unit tests with code coverage
./Invoke-Tests.ps1

# Run unit tests without coverage (faster)
./Invoke-Tests.ps1 -NoCoverage

# Run specific test type
./Invoke-Tests.ps1 -TestType Unit        # Unit tests only
./Invoke-Tests.ps1 -TestType Integration # Integration tests (requires Zoom API credentials)
./Invoke-Tests.ps1 -TestType Contract    # Contract tests
./Invoke-Tests.ps1 -TestType All         # All tests
```

### Running the Build Pipeline

```powershell
# Run full build pipeline
./Build/Start-Build.ps1

# Run specific task
./Build/Start-Build.ps1 -Task Test    # Run tests only
./Build/Start-Build.ps1 -Task Build   # Run tests and build
./Build/Start-Build.ps1 -Task Deploy  # Run full pipeline (default)
```

### Test Structure

```
Tests/
├── Unit/              # Unit tests (mocked API calls)
│   ├── Public/        # Tests for public functions
│   └── Private/       # Tests for private functions
├── Integration/       # Integration tests (live API)
├── Contract/          # OpenAPI contract validation
├── Fixtures/
│   └── MockResponses/ # JSON mock response files
└── Helpers/           # Test helper modules
```

### CI/CD

- **GitHub Actions**: Primary CI - runs on push/PR to main branches
- **AppVeyor**: Secondary CI - runs on push to main branches

### Environment Variables for Integration Tests

```powershell
$env:ZOOM_ACCOUNT_ID = "your-account-id"
$env:ZOOM_CLIENT_ID = "your-client-id"
$env:ZOOM_CLIENT_SECRET = "your-client-secret"
```
```

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add testing documentation to README"
```

---

## Final Folder Structure

After implementation:

```
PSZoom/
├── Build/
│   ├── Private/
│   │   ├── Get-BuildEnvironment.ps1      # NEW: Replaces BuildHelpers
│   │   └── Set-PSZoomModuleFunctions.ps1 # NEW: Replaces BuildHelpers
│   ├── psake.ps1                         # UPDATED: Uses custom helpers
│   ├── deploy.psdeploy.ps1               # UPDATED: Uses custom helpers
│   ├── Start-Build.ps1                   # UPDATED: Direct module install
│   └── Export-WikiDocumentation.ps1      # UNCHANGED
├── Tests/
│   ├── Unit/
│   │   ├── Build/                        # NEW: Tests for build helpers
│   │   │   ├── Get-BuildEnvironment.Tests.ps1
│   │   │   ├── Set-PSZoomModuleFunctions.Tests.ps1
│   │   │   └── Invoke-Tests.Tests.ps1
│   │   ├── Public/                       # EXISTING: Function tests
│   │   └── Private/                      # EXISTING: Private function tests
│   ├── Integration/                      # EXISTING
│   ├── Contract/                         # EXISTING
│   ├── Fixtures/                         # EXISTING
│   └── Helpers/                          # EXISTING
├── Invoke-Tests.ps1                      # NEW: Unified test runner
├── pester.config.psd1                    # EXISTING
├── pester.integration.config.psd1        # EXISTING
├── pester.contract.config.psd1           # NEW
├── AppVeyor.yml                          # UPDATED: No PSDepend/BuildHelpers
└── README.md                             # UPDATED: Testing docs
```

---

## Removed Files

- `Build/helpers/Install-PSDepend.ps1`
- `Build/build.requirements.psd1`
- `Test/` folder (entire legacy test directory)

---

## Dependencies Summary

**Before:**
- PSDepend (removed)
- BuildHelpers (removed)
- psake 4.9.0 (kept)
- PSDeploy 1.0.5 (kept)
- Pester 5.6.1 (kept)

**After:**
- psake 4.9.0
- PSDeploy 1.0.5
- Pester 5.6.1
