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

FormatTaskName "$('-' * (57 - {0}.length)){0}$('-' * (57 - {0}.length))" #Max width guidelines for Powershell is ~115

Task Default -Depends Deploy

Task Init {
    Set-Location $ProjectRoot
    Write-Host "Build System: $BuildSystem"
    Write-Host "Project Root: $ProjectRoot"
    Write-Host "Module Path: $ModulePath"
    Write-Host "Branch: $BranchName"
} -description 'Initialize build environment'

Task Test -Depends Init  {
    # Use unified test runner
    $testScriptPath = Join-Path $ProjectRoot 'Invoke-Tests.ps1'
    $testResults = & $testScriptPath -TestType Unit -OutputPath (Join-Path $ProjectRoot 'Tests') -PassThru

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

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($testResults.FailedCount -gt 0) {
        throw "Failed '$($testResults.FailedCount)' tests, build failed"
    }
} -description 'Run tests'

Task Build -Depends Test {
    # Update module functions in manifest
    Set-PSZoomModuleFunctions -ManifestPath $ManifestPath

    # Bump the module version if deploying
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